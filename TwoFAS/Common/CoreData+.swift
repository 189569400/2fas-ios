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
import CoreData

public extension NSPersistentContainer {
    @nonobjc convenience init(name: String, bundle: Bundle) {
        
        guard let modelURL = bundle.url(forResource: name, withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: modelURL)
            else {
                Log("Unable to located Core Data model", module: .storage)
                fatalError("Unable to located Core Data model")
            }
        
        self.init(name: name, managedObjectModel: mom)
    }
}

public extension NSManagedObject {
    @nonobjc func delete() {
        managedObjectContext?.delete(self)
    }
}

public extension Array {
    mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
    
    mutating func safeInsert(_ item: Element, at: Int) {
        let index = at > count ? count : at
        insert(item, at: index)
    }
}