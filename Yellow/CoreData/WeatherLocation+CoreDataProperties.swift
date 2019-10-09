//
//  WeatherLocation+CoreDataProperties.swift
//  Yellow
//
//  Created by Lyle on 29/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//
//

import CoreData

extension WeatherLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherLocation> {
        return NSFetchRequest<WeatherLocation>(entityName: "WeatherLocation")
    }
    
    @NSManaged public var isCurrentLocation: Bool
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String
    @NSManaged public var orderIndex: Int16
    
    @NSManaged public var country: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public var locality: String?
    @NSManaged public var postalCode: String?
    @NSManaged public var forecastUpdatedDate: Date?
    @NSManaged public var forecastResponseData: Data?
}
