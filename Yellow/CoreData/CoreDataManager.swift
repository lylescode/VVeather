//
//  CoreDataManager.swift
//  Yellow
//
//  Created by Lyle on 25/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import CoreData
import MapKit


final class CoreDataManager<ManagedObject: NSManagedObject> {
    private(set) var coreDataStack: CoreDataStack = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        return appDelegate.coreDataStack
    }()
    
    var mainContext: NSManagedObjectContext {
        coreDataStack.mainContext
    }
    
    public func performFetch(controller fetchedResultsController: NSFetchedResultsController<ManagedObject>,
                      completion: @escaping (Result<[ManagedObject], Error>) -> Void) {
        print(#function)
        do {
            try fetchedResultsController.performFetch()
            guard let fetchedObjects = fetchedResultsController.fetchedObjects else {
                fatalError()
            }
            completion(.success(fetchedObjects))
        } catch let error as NSError {
            completion(.failure(error))
        }
    }
    
}
