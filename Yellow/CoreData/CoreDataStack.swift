//
//  CoreDataStack.swift
//  Yellow
//
//  Created by Lyle on 22/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import CoreData

final class CoreDataStack {
    // MARK: - Properties
    private let modelName: String
    
    lazy var mainContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    // MARK: - Initializers
    init(modelName: String) {
        self.modelName = modelName
    }
}

// MARK: - Internal
extension CoreDataStack {
    func saveContext () {
        guard mainContext.hasChanges else { return }
        
        do {
            try mainContext.save()
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
