//
//  WeatherOverviewCell.swift
//  Yellow
//
//  Created by Lyle on 30/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

class WeatherOverviewCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var visualViewHeightConstraint: NSLayoutConstraint! {
        didSet {
            visualViewInitialHeight = visualViewHeightConstraint.constant
        }
    }
    @IBOutlet weak var visualView: UIView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    // MARK: - Properties
    private var visualViewInitialHeight: CGFloat = 0
    private var temperature: WeatherUnitConvertible?
    private var isFirstCell = false
    private var isCurrentLocation = false
    private var timeZone: TimeZone?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        resetLabels()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.timeZone = nil
        isCurrentLocation = false
        isFirstCell = false
        
        resetLabels()
    }
    
    override func layoutSubviews() {
        configureUI()
        super.layoutSubviews()
    }
    
    private func resetLabels() {
        timeLabel.text = "--:--"
        locationNameLabel.text = "--"
        temperatureLabel.text = "--°"
    }
    
    // MARK: - Configure
    func configure(indexPath: IndexPath, location: WeatherLocation? = nil) {
        isFirstCell = (indexPath.section == 0 && indexPath.row == 0)
        configureUI()
        
        if let location = location {
            configure(with: location)
        }
    }
    
    private func configureUI() {
        visualViewHeightConstraint.constant = isFirstCell ? visualViewInitialHeight + Device.safeAreaTop : visualViewInitialHeight
        clipsToBounds = !isFirstCell
    }
    
    private func configure(with location: WeatherLocation) {
        isCurrentLocation = location.isCurrentLocation
        if isCurrentLocation {
            locationNameLabel.text = location.name + " ⛳️"
            
        } else {
            locationNameLabel.text = location.name
        }
        do {
            if let forecastResponse = try location.forecastResponse() {
                //dump(forecastResponse)
                if let timeZone = TimeZone(identifier: forecastResponse.timezone) {
                    self.timeZone = timeZone
                }

                let temperature = WeatherUnit(temperature: forecastResponse.currently?.temperature)
                self.temperature = temperature
                
                if let temperatureValue = temperature.celsius?.value,
                    let temperatureColor = UIColor.color(from: temperatureValue)?.adjust(hue: 0, saturation: -0.25, brightness: 0) {
                    visualView.animator.color(temperatureColor)
                } else {
                    let color: UIColor = location.isCurrentLocation ? .red : .black
                    visualView.animator.color(color)
                }
                
                configureTemperatureLabel(with: temperature)
                configureTimeLabel()
            }
        } catch {
            print(#function, "error \(error), \(error.localizedDescription)")
        }
        
    }
    
    private func configureTemperatureLabel(with temperature: WeatherUnitConvertible) {
        temperatureLabel.text = temperature.temperatureString
    }
    
    private func configureTimeLabel() {
        if isCurrentLocation {
            timeLabel.text = ""
        } else if let timeZone = self.timeZone {
            let formatter = DateFormatter()
            formatter.timeZone = timeZone
            formatter.dateFormat = "a h:mm"
            timeLabel.text = formatter.string(from: Date())
        } else {
            timeLabel.text = "--:--"
        }
    }
    
    // MARK: - Updates
    func updateLocation(location: WeatherLocation) {
        configure(with: location)
        visualView.animator.splash()
    }
    func updateTime() {
        configureTimeLabel()
    }
    func updateTemperatureUnit() {
        if let temperature = self.temperature  {
            configureTemperatureLabel(with: temperature)
        }
    }
}
