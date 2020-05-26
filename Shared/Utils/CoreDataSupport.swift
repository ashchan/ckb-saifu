//
//  CoreDataSupport.swift
//  Csaifu
//
//  Created by James Chen on 2020/05/27.
//  Copyright © 2020 James Chen. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataSupport {
    var persistentContainer: NSPersistentContainer { mutating get }
}

extension CoreDataSupport {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores { description, error in
            if let error = error {
            }
        }
        return container
    }()
}
