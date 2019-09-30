//
//  WeatherNestedDailyCell.swift
//  Yellow
//
//  Created by Lyle on 30/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

class WeatherNestedDailyCell: UITableViewCell, WeatherForecastPointTypeCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var temperatureHighLabel: UILabel!
    @IBOutlet weak var temperatureLowLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dayLabel.text = ""
        iconView.image = nil
        temperatureHighLabel.text = "--"
        temperatureLowLabel.text = "--"
    }
    
    
    func configure(timeZone: TimeZone, forecastPoint: ForecastPoint) {
        
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "EEEE"
        dayLabel.text = formatter.string(from: Date(timeIntervalSince1970: forecastPoint.time))
        
        if let icon = forecastPoint.icon {
            iconView.image = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate)
        }
        
        let temperatureHigh = WeatherUnit(temperature: forecastPoint.temperatureHigh)
        let temperatureLow = WeatherUnit(temperature: forecastPoint.temperatureLow)
        
        temperatureHighLabel.text = temperatureHigh.temperatureValueString
        temperatureLowLabel.text = temperatureLow.temperatureValueString
        
    }
    
}
