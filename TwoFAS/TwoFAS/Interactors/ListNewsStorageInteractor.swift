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

import Foundation
import Common

protocol ListNewsStorageInteracting: AnyObject {
    func createNewsEntry(from newsEntry: ListNewsEntry)
    func deleteNewsEntry(with newsEntry: ListNewsEntry)
    func updateNewsEntry(with newsEntry: ListNewsEntry)
    func markNewsEntryAsRead(with newsEntry: ListNewsEntry)
    func listAll() -> [ListNewsEntry]
    func hasNewsEntriesUnreadItems() -> Bool
    func markAllAsRead()
}

final class ListNewsStorageInteractor {
    private let mainRepository: MainRepository
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension ListNewsStorageInteractor: ListNewsStorageInteracting {
    func createNewsEntry(from newsEntry: ListNewsEntry) {
        Log("ListNewsStorageInteractor - createNewsEntry", module: .interactor)
        mainRepository.createNewsEntry(from: newsEntry)
    }
    
    func deleteNewsEntry(with newsEntry: ListNewsEntry) {
        Log("ListNewsStorageInteractor - deleteNewsEntry", module: .interactor)
        mainRepository.deleteNewsEntry(with: newsEntry)
    }
    
    func updateNewsEntry(with newsEntry: ListNewsEntry) {
        Log("ListNewsStorageInteractor - updateNewsEntry", module: .interactor)
        mainRepository.updateNewsEntry(with: newsEntry)
    }
    
    func markNewsEntryAsRead(with newsEntry: ListNewsEntry) {
        Log("ListNewsStorageInteractor - markNewsEntryAsRead", module: .interactor)
        mainRepository.markNewsEntryAsRead(with: newsEntry)
    }
    
    func listAll() -> [ListNewsEntry] {
        mainRepository.listAll()
    }
    
    func hasNewsEntriesUnreadItems() -> Bool {
        mainRepository.hasNewsEntriesUnreadItems()
    }
    
    func markAllAsRead() {
        Log("ListNewsStorageInteractor - markAllAsRead", module: .interactor)
        mainRepository.markAllNewsEntriesAsRead()
    }
}