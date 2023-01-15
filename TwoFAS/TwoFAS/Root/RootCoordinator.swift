//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2023 Two Factor Authentication Service, Inc.
//  Contributed by Zbigniew Cisiński. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <https://www.gnu.org/licenses/>
//

import UIKit
import Storage
import Protection
import PushNotifications
import CodeSupport
import Common
import Token
import Sync
import TimeVerification

final class RootCoordinator: Coordinator {
    private enum State {
        case initial
        case login
        case intro
        case main
    }
    
    private let service: ServiceHandler
    private let initialStateDataController = PermissionsStateDataController()
    private let pushNotifications: PushNotifications
    private let security: SecurityProtocol
    private let protection: Protection
    private let storage: Storage
    private let timerHandler: TimerHandler
    private let introDataController: IntroductionDataController
    private let timeVerificationController: TimeVerificationController
    private let sync: CloudHandlerType
    private let viewPathController = ViewPathController()
    private let fileHandler: FileOpenHandler
    private let initializeSyncOnFirstRun: InitializeSyncOnFirstRun
    private let categoryHandler: CategoryHandler
    private let sectionHandler: SectionHandler
    
    private var pushNotificationRegistrationInteractor: PushNotificationRegistrationInteracting?
    private var registerDeviceInteractor: RegisterDeviceInteracting?
    private var linkInteractor: LinkInteracting?
    private var cameraPermissionInteractor: CameraPermissionInteracting?
        
    let rootViewController: RootViewController
    
    private var currentState = State.initial {
        didSet {
            Log("RootCoordinator: new currentState: \(currentState)")
        }
    }
    
    override init() {
        ServiceIcon.log = { AnalyticsLog(.missingIcon($0)) }
        protection = Protection()
        
        EncryptionHolder.initialize(with: protection.localKeyEncryption)
        
        storage = Storage(readOnly: false) { error in
            DebugLog(error)
        }
        
        LogStorage.setStorage(storage.log)
        
        fileHandler = FileOpenHandler()
        
        pushNotifications = PushNotifications(app: UIApplication.shared)
        
        let serviceMigration = ServiceMigrationController(storageRepository: storage.storageRepository)
        
        SyncInstance.initialize(commonSectionHandler: storage.section, commonServiceHandler: storage.service) {
            DebugLog("Sync: \($0)")
        }
        SyncInstance.migrateStoreIfNeeded()
        serviceMigration.migrateIfNeeded()
                        
        service = storage.service
        categoryHandler = storage.category
        sectionHandler = storage.section
        
        security = Security(biometric: protection.biometricAuth, codeStorage: protection.codeStorage)
                        
        timeVerificationController = TimeVerificationController()
                
        timerHandler = TokenHandler.timer
        
        sync = SyncInstance.getCloudHandler()
        
        introDataController = IntroductionDataController()
        initializeSyncOnFirstRun = InitializeSyncOnFirstRun()
        
        Theme.applyAppearance()
        SpinnerViewLocalizations.voiceOverSpinner = T.Voiceover.spinner
        
        rootViewController = RootViewController()
        
        super.init()
        
        storage.addUserPresentableError { [weak self] error in
            let alert = AlertControllerDismissFlow(title: T.Commons.error, message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: T.Commons.ok, style: .cancel, handler: nil))
            self?.rootViewController.present(alert, animated: false, completion: nil)
        }
                
        introDataController.wasFirstRun = { [weak self] in self?.initializeSyncOnFirstRun.markAsFirstRun() }
        
        _ = MainRepositoryImpl(
            service: service,
            pushNotifications: pushNotifications,
            cameraPermissions: CodeSupport.cameraPermissions,
            security: security,
            protectionModule: protection,
            storage: storage,
            timerHandler: timerHandler,
            counterHandler: TokenHandler.counter,
            introDataController: introDataController,
            timeVerificationController: timeVerificationController,
            sync: sync,
            viewPathController: viewPathController,
            fileHandler: fileHandler,
            initializeSyncOnFirstRun: initializeSyncOnFirstRun,
            categoryHandler: categoryHandler,
            sectionHandler: sectionHandler,
            cloudHandler: sync,
            logDataChange: SyncInstance.logDataChange
        )
        
        timeVerificationController.offsetUpdated = { [weak self] in
            self?.timerHandler.setOffset(offset: $0)
            self?.sync.setTimeOffset($0)
            MainRepositoryImpl.shared.reloadWidgets()
        }
        
        let pushInteractor = InteractorFactory.shared.pushNotificationRegistrationInteractor()
        pushNotificationRegistrationInteractor = pushInteractor

        let camera = CameraPermissionInteractor(mainRepository: MainRepositoryImpl.shared)
        cameraPermissionInteractor = camera
        
        initialStateDataController.set(children: [pushInteractor, camera])
        initialStateDataController.initialize()
        
        registerDeviceInteractor = InteractorFactory.shared.registerDeviceInteractor()
        registerDeviceInteractor?.initialize()
        
        linkInteractor = InteractorFactory.shared.linkInteractor()
    }
    
    // MARK: - handling app delegates
    
    func applicationWillResignActive() {
        Log("App: applicationWillResignActive")
        ToastNotification.hideAll()
        storage.save()
        guard !security.isAuthenticatingUsingBiometric else { return }
    }
    
    func applicationWillEnterForeground() {
        Log("App: applicationWillEnterForeground")
        security.applicationWillEnterForeground()
        initialStateDataController.initialize()
        handleViewFlow()
    }
    
    func applicationDidEnterBackground() {
        Log("App: applicationDidEnterBackground")
        lockApplicationIfNeeded()
    }
    
    func applicationDidBecomeActive() {
        Log("App: applicationDidBecomeActive")
        sync.synchronize()
        timeVerificationController.startVerification()
        security.applicationDidBecomeActive()
        fileHandler.appBecomeActive()
        RatingController.uiIsVisible()
    }
    
    func applicationWillTerminate() {
        Log("App: applicationWillTerminate")
        storage.save()
    }
    
    func shouldHandleURL(url: URL) -> Bool {
        Log("App: shouldHandleURL")
        return (linkInteractor?.shouldHandleURL(url: url) == true) || fileHandler.shouldHandleURL(url: url)
    }
    
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        Log("App: didRegisterForRemoteNotifications")
        pushNotifications.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    func didFailToRegisterForRemoteNotifications(with error: Error) {
        Log("App: didFailToRegisterForRemoteNotifications")
        pushNotifications.didFailToRegisterForRemoteNotifications(with: error)
    }
    
    func didReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        Log("App: didReceiveRemoteNotification")
        SyncInstance.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    override func start() {
        handleViewFlow()
    }
    
    // MARK: - RootCoordinatorDelegate methods
    
    func handleViewFlow() {
        let coldRun = (currentState == .initial)
        
        Log("RootCoordinator: Changing state for: \(currentState)")
        
        if introDataController.shouldShow {
            presentIntroduction()
        } else if security.isAuthenticationRequired {
            presentLogin(immediately: coldRun)
        } else {
            presentMain(immediately: coldRun)
        }
    }
    
    // MARK: - Private methods
    
    private func presentIntroduction() {
        guard currentState != .intro else { return }
        changeState(.intro)
        Log("Presenting Introduction")
        let navigationController = CommonNavigationController()
        let intro = IntroductionCoordinator(dataController: introDataController)
        
        let adapter = PreviousToCurrentCoordinatorAdapter(
            navigationController: navigationController,
            coordinator: intro
        )
        adapter.parentCoordinatorDelegate = self
        addChild(adapter)
        
        rootViewController.present(navigationController, immediately: false, animationType: .alpha)
        intro.start()
    }
    
    private func presentMain(immediately: Bool) {
        guard currentState != .main else { return }
        let immediately = !(currentState == .login || currentState == .intro)
        changeState(.main)
        
        let dependency = MainCoordinatorDependencies(
            service: service,
            codeStorage: protection.codeStorage,
            biometricAuth: protection.biometricAuth,
            timerHandler: timerHandler,
            security: security,
            rootViewController: rootViewController,
            timeVerificationController: timeVerificationController,
            accessTokenStorage: protection.tokenStorage,
            viewPath: viewPathController,
            sync: sync,
            fileHandler: fileHandler,
            initializeSyncOnFirstRun: initializeSyncOnFirstRun,
            categoryHandler: categoryHandler,
            sectionHandler: sectionHandler,
            extensionStorage: protection.extensionsStorage
        )
        
        let mainCoordinator = MainCoordinator(dependency: dependency, showImmidiately: immediately)
        
        mainCoordinator.parentCoordinatorDelegate = self
        addChild(mainCoordinator)
        mainCoordinator.start()
    }
    
    private func presentLogin(immediately: Bool) {
        guard currentState != .login else { return }
        changeState(.login)
        
        UIApplication.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
        let loginCoordinator = LoginCoordinator(
            security: security,
            leftButtonDescription: nil,
            rootViewController: rootViewController,
            showImmediately: immediately
        )
        loginCoordinator.parentCoordinatorDelegate = self
        addChild(loginCoordinator)
        loginCoordinator.start()
    }
    
    private func lockApplicationIfNeeded() {
        security.lockApplication()
        
        if security.isAuthenticationRequired {
            presentLogin(immediately: true)
        }
    }
    
    private func changeState(_ newState: State) {
        currentState = newState
        removeAllChildCoordinators()
    }
    
    // MARK: Callbacks from CoordinatorDelegate
    
    override func didFinish() {
        removeAllChildCoordinators()
        handleViewFlow()
    }
}