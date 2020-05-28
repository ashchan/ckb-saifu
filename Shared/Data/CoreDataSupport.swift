//
//  CoreDataSupport.swift
//  Csaifu
//
//  Created by James Chen on 2020/05/28.
//  Copyright © 2020 James Chen. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataSupport {
    var managedObjectContext: NSManagedObjectContext { get }
    var managedObjectModel: NSManagedObjectModel { get }
}

extension CoreDataSupport {
    var managedObjectContext: NSManagedObjectContext {
        (Application.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    var managedObjectModel: NSManagedObjectModel {
        (Application.shared.delegate as! AppDelegate).persistentContainer.managedObjectModel
    }
}

extension NSExpressionDescription {
    static func description(for name: String, expression: NSExpression, resultType: NSAttributeType) -> NSExpressionDescription {
        let description = NSExpressionDescription()
        description.name = name
        description.expression = expression
        description.expressionResultType = resultType
        return description
    }
}
