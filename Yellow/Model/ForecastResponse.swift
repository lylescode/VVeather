//
//  ForecastResponse.swift
//  Yellow
//
//  Created by Lyle on 22/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import Foundation

struct ForecastResponse: Decodable {
    // MARK: - Properties
    let timezone: String
    let latitude: Double
    let longitude: Double
    
    let currently: ForecastPoint?
    let hourly: ForecastBlock?
    let daily: ForecastBlock?
    
    var coordinateString: String {
        return "\(latitude), \(longitude)"
    }
}
