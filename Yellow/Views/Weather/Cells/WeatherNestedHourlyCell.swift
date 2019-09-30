//
//  WeatherNestedHourlyCell.swift
//  Yellow
//
//  Created by Lyle on 30/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

class WeatherNestedHourlyCell: UICollectionViewCell, WeatherForecastPointTypeCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Configure
    func configure(timeZone: TimeZone, forecastPoint: ForecastPoint) {
        
        // TODO: DateFormatter 다듬자
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "a h"
        
        let hourFormatter = DateFormatter()
        hourFormatter.timeZone = timeZone
        hourFormatter.dateFormat = "ddHH"
        
        if hourFormatter.string(from: Date(timeIntervalSince1970: forecastPoint.time)) == hourFormatter.string(from: Date()){
            hourLabel.text = "지금"
        } else {
            hourLabel.text = formatter.string(from: Date(timeIntervalSince1970: forecastPoint.time)) + "시"
        }
        
        if let icon = forecastPoint.icon {
            iconView.image = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate)
        }
        
        let temperature = WeatherUnit(temperature: forecastPoint.temperature)
        temperatureLabel.text = temperature.temperatureString
        
    }
}
