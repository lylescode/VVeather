//
//  CoreDataManager+WeatherLocation.swift
//  Yellow
//
//  Created by Lyle on 28/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import Foundation
import CoreData
import MapKit

extension CoreDataManager where ManagedObject == WeatherLocation {
    
    enum SaveError: Error {
        case invalidCoordinate
        case nameRequired
        case placemarkExists
        case limits
    }
    
    private var locationLimitCount: Int {
        return 20
    }
    
    func fetchedResultsController() -> NSFetchedResultsController<ManagedObject> {
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest(),
                                                                  managedObjectContext: mainContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        return fetchedResultsController
    }

    func fetchRequest() -> NSFetchRequest<ManagedObject> {
        let fetchRequest: NSFetchRequest<ManagedObject> = NSFetchRequest<ManagedObject>(entityName: String(describing: ManagedObject.self))
        
        let sortDescriptor = NSSortDescriptor(key: #keyPath(WeatherLocation.isCurrentLocation), ascending: false)
        let orderIndexSortDescriptor = NSSortDescriptor(key: #keyPath(WeatherLocation.orderIndex), ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor, orderIndexSortDescriptor]
        return fetchRequest
    }
    
    func addCurrentLocation(from placemark: CLPlacemark,
                            completion: ((Result<ManagedObject, Error>) -> Void)? = nil) {
        let context = mainContext
        
        guard let coordinate = placemark.location?.coordinate else {
            completion?(.failure(SaveError.invalidCoordinate))
            return
        }
        
        let currentLocation = currentWeatherLocationExists(context: context) ?? WeatherLocation(context: context)

        print(#function, "placemark : \(placemark)")
        currentLocation.isCurrentLocation = true
        currentLocation.creationDate = Date()
        currentLocation.orderIndex = 0
        currentLocation.name = placemark.locality ?? placemark.name ?? placemark.country ?? ""
        currentLocation.latitude = coordinate.latitude
        currentLocation.longitude = coordinate.longitude
        
        currentLocation.country = placemark.country
        currentLocation.postalCode = placemark.postalCode
        currentLocation.locality = placemark.locality
        
        currentLocation.forecastUpdatedDate = nil
        currentLocation.isForecastUpdating = false

        context.perform {
            do {
                try context.save()
                completion?(.success(currentLocation))
            } catch let error as NSError {
                completion?(.failure(error))
            }
        }
    }
    
    func addLocation(from placemark: MKPlacemark,
                     completion: ((Result<ManagedObject, Error>) -> Void)? = nil) {

        let context = mainContext
        let fetchRequest: NSFetchRequest<WeatherLocation> = WeatherLocation.fetchRequest()
        
        guard let fetchedObjectsCount = try? mainContext.count(for: fetchRequest) else {
            fatalError()
        }
        
        guard let location = placemark.location else {
            completion?(.failure(SaveError.invalidCoordinate))
            return
        }
        
        if let weatherLocation = weatherLocationExists(placemark, context: context) {
            completion?(.success(weatherLocation))
        } else if weatherLocationLimits(context: context) {
            completion?(.failure(SaveError.limits))
        } else {
            
            print(#function, "placemark : \(placemark)")
            let weatherLocation = WeatherLocation(context: context)
            weatherLocation.creationDate = Date()
            weatherLocation.orderIndex = Int16(fetchedObjectsCount)
            weatherLocation.name = placemark.name ?? ""
            weatherLocation.latitude = location.coordinate.latitude
            weatherLocation.longitude = location.coordinate.longitude
            
            weatherLocation.country = placemark.country
            weatherLocation.postalCode = placemark.postalCode
            weatherLocation.locality = placemark.locality
            
            context.perform {
                do {
                    try context.save()
                    completion?(.success(weatherLocation))
                } catch let error as NSError {
                    completion?(.failure(error))
                }
            }
        }
    }
    
    func delete(_ fetchedResultsController: NSFetchedResultsController<ManagedObject>,
                at index: Int) {
        
        let context = mainContext
        guard var fetchedObjects = fetchedResultsController.fetchedObjects else {
            return
        }
        let weatherLocation = fetchedResultsController.object(at: IndexPath(row: index, section: 0))
        guard !weatherLocation.isCurrentLocation else { return }
        
        context.delete(weatherLocation)
        fetchedObjects.remove(at: index)
        
        var orderIndex: Int16 = 0
        for object in fetchedObjects {
            object.orderIndex = orderIndex
            orderIndex += 1
        }
        saveContext()
    }
    
    func move(_ fetchedResultsController: NSFetchedResultsController<ManagedObject>,
                     from fromIndex: Int, to toIndex: Int) {
        guard var fetchedObjects = fetchedResultsController.fetchedObjects else {
            return
        }
        
        let object = fetchedObjects[fromIndex]
        fetchedObjects.remove(at: fromIndex)
        fetchedObjects.insert(object, at: toIndex)

        var orderIndex: Int16 = 0
        for object in fetchedObjects {
            object.orderIndex = orderIndex
            orderIndex += 1
        }
        saveContext()
    }
    
    func saveContext() {
        coreDataStack.saveContext()
    }
    
    private func weatherLocationLimits(context: NSManagedObjectContext) -> Bool {
        let fetchRequest: NSFetchRequest<WeatherLocation> = WeatherLocation.fetchRequest()
        do {
            let count = try context.count(for: fetchRequest)
            print(#function, locationLimitCount, count)
            return !(count < locationLimitCount)
        } catch {
            fatalError()
        }
    }
    
    private func weatherLocationExists(_ placemark: MKPlacemark, context: NSManagedObjectContext) -> WeatherLocation? {
        let fetchRequest: NSFetchRequest<WeatherLocation> = WeatherLocation.fetchRequest()
        fetchRequest.fetchLimit =  1
        fetchRequest.predicate = NSPredicate(format: "name == %@", placemark.name ?? "")

        do {
            let results: [WeatherLocation] = try context.fetch(fetchRequest)
            return results.first
        } catch {
            fatalError()
        }
    }
    
    private func currentWeatherLocationExists(context: NSManagedObjectContext) -> WeatherLocation? {
        let fetchRequest: NSFetchRequest<WeatherLocation> = WeatherLocation.fetchRequest()
        fetchRequest.fetchLimit =  1
        fetchRequest.predicate = NSPredicate(format: "isCurrentLocation == true")

        do {
            let results: [WeatherLocation] = try context.fetch(fetchRequest)
            return results.first
        } catch {
            fatalError()
        }
    }
}

extension NSFetchedResultsChangeType {
    var typeString: String {
        switch self {
        case .insert:
            return "insert"
        case .delete:
            return "delete"
        case .move:
            return "move"
        case .update:
            return "update"
        @unknown default:
            return "Unknown"
        }
    }
}
