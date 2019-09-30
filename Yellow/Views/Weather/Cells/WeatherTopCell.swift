//
//  WeatherTopCell.swift
//  Yellow
//
//  Created by Lyle on 30/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

class WeatherTopCell: UICollectionViewCell, WeatherLocationCellType {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var hourlyLabel: UILabel!
    
    @IBOutlet weak var temperatureHighLabel: UILabel!
    @IBOutlet weak var temperatureLowLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Configure
    func configure(location: WeatherLocation, forecastResponse: ForecastResponse) {
        
        locationLabel.text = location.name
        summaryLabel.text = forecastResponse.currently?.summary
        
        let temperature = WeatherUnit(temperature: forecastResponse.currently?.temperature)
        temperatureLabel.text = temperature.temperatureString
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: forecastResponse.timezone)
        formatter.dateFormat = "EEEE"
        dayLabel.text = formatter.string(from: Date())
        
        
        let forecastDaily = forecastResponse.daily
        let today = forecastDaily?.data.first
        let temperatureHigh = WeatherUnit(temperature: today?.temperatureHigh)
        let temperatureLow = WeatherUnit(temperature: today?.temperatureLow)
        
        temperatureHighLabel.text = temperatureHigh.temperatureValueString
        temperatureLowLabel.text = temperatureLow.temperatureValueString
        
    }
}
