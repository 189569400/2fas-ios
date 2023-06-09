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

extension MainRepositoryImpl {
    func storeNewsCompletions(_ completion: @escaping () -> Void) {
        newsCompletions.append(completion)
    }
    
    func callAndClearNewsCompletions() {
        newsCompletions.forEach({ $0() })
        newsCompletions = []
    }
    
    func setIsFetchingNews(_ isFetching: Bool) {
        isFetchingNewsFlag = isFetching
    }
    
    func isFetchingNews() -> Bool {
        isFetchingNewsFlag
    }
    
    func saveLastNewsFetch(_ lastFetch: Date) {
        lastFetchedNewsTimestamp = lastFetch
    }
    
    func lastNewsFetch() -> Date? {
        lastFetchedNewsTimestamp
    }
    
    func createNewsEntry(from newsEntry: ListNewsEntry) {
        storageRepository.createNewsEntry(from: newsEntry)
    }
    
    func deleteNewsEntry(with newsEntry: ListNewsEntry) {
        storageRepository.deleteNewsEntry(with: newsEntry)
    }
    
    func updateNewsEntry(with newsEntry: ListNewsEntry) {
        storageRepository.updateNewsEntry(with: newsEntry)
    }
    
    func markNewsEntryAsRead(with newsEntry: ListNewsEntry) {
        storageRepository.markNewsEntryAsRead(with: newsEntry)
    }
    
    func listAllNews() -> [ListNewsEntry] {
        storageRepository.listAllNews()
    }
    
    func listAllFreshlyAddedNews() -> [ListNewsEntry] {
        storageRepository.listAllFreshlyAddedNews()
    }
    
    func hasNewsEntriesUnreadItems() -> Bool {
        storageRepository.hasNewsEntriesUnreadItems()
    }
    
    func markAllNewsEntriesAsRead() {
        storageRepository.markAllAsRead()
    }
}
