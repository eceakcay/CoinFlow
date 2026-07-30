//
//  CoreDataManager.swift
//  CoinFlow
//
//  Created by Ece Akcay on 24.07.2026.
//


import Foundation
import CoreData

final class CoreDataManager {

    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    private init() {
        self.persistentContainer = NSPersistentContainer(name: "CoinFlow")

        self.persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data store could not be loaded: \(error.localizedDescription)")
            }
        }

        self.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func saveContext() throws {
        let context = persistentContainer.viewContext

        if context.hasChanges {
            try context.save()
        }
    }
}
