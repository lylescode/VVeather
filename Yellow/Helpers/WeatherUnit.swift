//
//  WeatherUnit.swift
//  Yellow
//
//  Created by Lyle on 22/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import Foundation

extension Measurement where UnitType : UnitTemperature  {
    var valueString: String {
        switch self.unit {
        case .celsius, .fahrenheit:
            return "\(Int(self.value))°"
        case .kelvin:
            return "\(Int(self.value))K"
        default:
            return "\(Int(self.value))"
        }
    }
}

protocol WeatherUnitConvertible {
    var temperature: Double? { get }
}

extension WeatherUnitConvertible {
    
    var fahrenheit: Measurement<UnitTemperature>? {
        return celsius?.converted(to: .fahrenheit)
    }
    var celsius: Measurement<UnitTemperature>? {
        guard let temperature = self.temperature else { return nil }
        return Measurement(value: temperature, unit: UnitTemperature.celsius)
    }
    
    var temperatureValueString: String? {
        if WeatherUnit.currentUnitSymbol == WeatherUnit.celsiusSymbol {
            return "\(Int(celsius?.value ?? 0))"
        } else {
            return "\(Int(fahrenheit?.value ?? 0))"
        }
    }
    var temperatureString: String? {
        if WeatherUnit.currentUnitSymbol == WeatherUnit.celsiusSymbol {
            return celsius?.valueString
        } else {
            return fahrenheit?.valueString
        }
    }
}


struct WeatherUnit: WeatherUnitConvertible {
    var temperature: Double?
    
    static let fahrenheitSymbol: String = "°F"
    static let celsiusSymbol: String = "°C"
    
    static var currentUnitSymbol: String {
        if let symbol = UserDefaults.standard.object(forKey: UserDefaultsKey.UnitTemperatureSymbol) as? String {
            return symbol
        } else {
            saveTemperatureUnit(celsiusSymbol)
            return celsiusSymbol
        }
    }
    
    static func saveTemperatureUnit(_ symbol: String) {
        UserDefaults.standard.set(symbol, forKey: UserDefaultsKey.UnitTemperatureSymbol)
    }
    
    static func toggleTemperatureUnit() -> String {
        if currentUnitSymbol == celsiusSymbol {
            saveTemperatureUnit(fahrenheitSymbol)
            return fahrenheitSymbol
        } else {
            saveTemperatureUnit(celsiusSymbol)
            return celsiusSymbol
        }
    }
    
    static func degreesToCompass(degrees: Double) -> String {
        let val = ((degrees / 22.5) + 0.5).rounded(.down)
        let compassStrings = ["북", "북북동", "북동", "동북동", "동", "동남동", "남동", "남남동", "남", "남남서", "남서", "서남서", "서", "서북서", "북서", "북북서"];
        return compassStrings[Int(val.truncatingRemainder(dividingBy: 16))]
    }
    
}
