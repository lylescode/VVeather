//
//  WeatherNestedTodayCell.swift
//  Yellow
//
//  Created by Lyle on 01/10/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

class WeatherNestedTodayCell: UITableViewCell {
    enum TodayCellType: String {
        case Sunrise, Sunset
        case PrecipProbability, Humidity
        case Wind, ApparentTemperature
        case PrecipIntensity, Pressure
        case Visibility, UVndex
        
        static var captionString: [TodayCellType: String] {
            [.Sunrise: "일출",
             .Sunset: "일몰",
             .PrecipProbability: "비 올 확률",
             .Humidity: "습도",
             .Wind: "바람",
             .ApparentTemperature: "체감",
             .PrecipIntensity: "강수량",
             .Pressure: "기압",
             .Visibility: "가시거리",
             .UVndex: "자외선지수"]
        }
    }
    
    @IBOutlet weak var lCaptionLabel: UILabel!
    @IBOutlet weak var lDecriptionLabel: UILabel!
    
    @IBOutlet weak var rCaptionLabel: UILabel!
    @IBOutlet weak var rDecriptionLabel: UILabel!
    
    typealias LabelGroup = (caption: UILabel, description: UILabel)
    lazy var labelGroups: [LabelGroup] = [(caption: lCaptionLabel, description: lDecriptionLabel),
                                         (caption: rCaptionLabel, description: rDecriptionLabel)]
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lCaptionLabel.text = ""
        lDecriptionLabel.text = ""
        rCaptionLabel.text = ""
        rDecriptionLabel.text = ""
    }
    
    func configure(cellTypes: [TodayCellType], timeZone: TimeZone, forecastResponse: ForecastResponse) {
        
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "a h:mm"
        
        let today = forecastResponse.daily?.data.first
        let currently = forecastResponse.currently
        var groupIndex = 0
        for cellType in cellTypes {
            
            let labelGroup = labelGroups[groupIndex]
            labelGroup.caption.text = TodayCellType.captionString[cellType]
            labelGroup.description.text = "--"
            switch cellType {
            case .Sunrise:
                if let sunriseTime = today?.sunriseTime {
                labelGroup.description.text = formatter.string(from: Date(timeIntervalSince1970: sunriseTime))
                }
            case .Sunset:
                if let sunsetTime = today?.sunsetTime {
                    labelGroup.description.text = formatter.string(from: Date(timeIntervalSince1970: sunsetTime))
                }
            case .PrecipProbability:
                if let precipProbability = currently?.precipProbability {
                    labelGroup.description.text = "\(Int(precipProbability * 100))%"
                }
            case .Humidity:
                if let humidity = currently?.humidity {
                    labelGroup.description.text = "\(Int(humidity * 100))%"
                }
            case .Wind:
                if let windBearing = currently?.windBearing, let windSpeed = currently?.windSpeed {
                    labelGroup.description.text = "\(WeatherUnit.degreesToCompass(degrees: windBearing)) \(Int(windSpeed))m/s"
                }
            case .ApparentTemperature:
                if let apparentTemperature = currently?.apparentTemperature {
                    let temperature = WeatherUnit(temperature: apparentTemperature)
                    labelGroup.description.text = temperature.temperatureString
                }
                break
            case .PrecipIntensity:
                if let precipIntensity = currently?.precipIntensity {
                    labelGroup.description.text = "\(Int(precipIntensity * 10))cm"
                }
                break
            case .Pressure:
                if let pressure = currently?.pressure {
                    labelGroup.description.text = "\(Int(pressure))pHa"
                }
                break
            case .Visibility:
                if let visibility = currently?.visibility {
                    labelGroup.description.text = String(format: "%.1fkm", visibility)
                }
                break
            case .UVndex:
                if let uvIndex = currently?.uvIndex {
                    labelGroup.description.text = "\(Int(uvIndex))"
                }
                break
            }
            
            groupIndex += 1
        }
    }
}
