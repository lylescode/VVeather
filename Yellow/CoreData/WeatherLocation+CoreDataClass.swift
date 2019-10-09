//
//  WeatherLocation+CoreDataClass.swift
//  Yellow
//
//  Created by Lyle on 29/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//
//

import CoreData

@objc(WeatherLocation)
public class WeatherLocation: NSManagedObject {
    
    var isForecastUpdating: Bool = false
    
    func forecastResponse() throws -> ForecastResponse? {
        guard let data = self.forecastResponseData else { return nil }
        do {
            let forecastResponse = try JSONDecoder().decode(ForecastResponse.self, from: data)
            return forecastResponse
        } catch (let error) {
            print(#function, "error \(error), \(error.localizedDescription)")
            forecastResponseData = nil
            forecastUpdatedDate = nil
            try self.managedObjectContext?.save()
            return nil
        }
    }
}
