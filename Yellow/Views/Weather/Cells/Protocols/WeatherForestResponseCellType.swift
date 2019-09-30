//
//  WeatherForestResponseCellType.swift
//  Yellow
//
//  Created by Lyle on 01/10/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

protocol WeatherForestResponseCellType: UIView {
    func configure(timeZone: TimeZone, forecastResponse: ForecastResponse)
}

