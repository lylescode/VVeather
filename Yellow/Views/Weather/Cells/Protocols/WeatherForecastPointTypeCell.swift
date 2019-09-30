//
//  WeatherForecastPointTypeCell.swift
//  Yellow
//
//  Created by Lyle on 01/10/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

protocol WeatherForecastPointTypeCell: UIView {
    func configure(timeZone: TimeZone, forecastPoint: ForecastPoint)
}
