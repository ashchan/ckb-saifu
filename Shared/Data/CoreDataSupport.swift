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

    func deleteTable(entity: NSManagedObject.Type)
}

extension CoreDataSupport {
    var managedObjectContext: NSManagedObjectContext {
        (Application.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    var managedObjectModel: NSManagedObjectModel {
        (Application.shared.delegate as! AppDelegate).persistentContainer.managedObjectModel
    }

    func deleteTable(entity: NSManagedObject.Type) {
        let request = NSBatchDeleteRequest(fetchRequest: entity.fetchRequest())
        request.resultType = .resultTypeObjectIDs
        do {
            let result = try managedObjectContext.execute(request) as! NSBatchDeleteResult
            if let objectIDs = result.result as? [NSManagedObjectID], !objectIDs.isEmpty {
                let changes = [NSInsertedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [managedObjectContext])
            }
        } catch {
            print("Delete \(entity.description()) DB error: " + error.localizedDescription)
        }
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
