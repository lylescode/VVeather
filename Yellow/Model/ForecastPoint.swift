//
//  ForecastPoint.swift
//  Yellow
//
//  Created by Lyle on 22/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import Foundation

struct ForecastPoint: Decodable {
    // MARK: - Properties
    let summary: String?                        // optional. A human-readable text summary of this data point. (This property has millions of possible values, so don’t use it for automated purposes: use the icon property, instead!)
    let time: Double                            // required. The UNIX time at which this data point begins. minutely data point are always aligned to the top of the minute, hourly data point objects to the top of the hour, and daily data point objects to midnight of the day, all according to the local time zone.
    let icon: String?                           // optional. A machine-readable text summary of this data point, suitable for selecting an icon for display. If defined, this property will have one of the following values: clear-day, clear-night, rain, snow, sleet, wind, fog, cloudy, partly-cloudy-day, or partly-cloudy-night. (Developers should ensure that a sensible default is defined, as additional values, such as hail, thunderstorm, or tornado, may be defined in the future.)
    
    let apparentTemperature: Double?            // optional, only on hourly. The apparent (or “feels like”) temperature in degrees Fahrenheit.
    let apparentTemperatureHigh: Double?        // optional, only on daily. The daytime high apparent temperature.
    let apparentTemperatureHighTime: Double?    // optional, only on daily. The UNIX time representing when the daytime high apparent temperature occurs.
    let apparentTemperatureLow: Double?         // optional, only on daily. The overnight low apparent temperature.
    let apparentTemperatureLowTime: Double?     // optional, only on daily. The UNIX time representing when the overnight low apparent temperature occurs.
    let apparentTemperatureMax: Double?         // optional, only on daily. The maximum apparent temperature during a given date.
    let apparentTemperatureMaxTime: Double?     // optional, only on daily. The UNIX time representing when the maximum apparent temperature during a given date occurs.
    let apparentTemperatureMin: Double?         // optional, only on daily. The minimum apparent temperature during a given date.
    let apparentTemperatureMinTime: Double?     // optional, only on daily. The UNIX time representing when the minimum apparent temperature during a given date occurs.
    let cloudCover: Double?                     // optional. The percentage of sky occluded by clouds, between 0 and 1, inclusive.
    let dewPoint: Double?                       // optional. The dew point in degrees Fahrenheit.
    let humidity: Double?                       // optional. The relative humidity, between 0 and 1, inclusive.
    let moonPhase: Double?                      // optional, only on daily. The fractional part of the lunation number during the given day: a value of 0 corresponds to a new moon, 0.25 to a first quarter moon, 0.5 to a full moon, and 0.75 to a last quarter moon. (The ranges in between these represent waxing crescent, waxing gibbous, waning gibbous, and waning crescent moons, respectively.)
    let nearestStormBearing: Double?            // optional, only on currently. The approximate direction of the nearest storm in degrees, with true north at 0° and progressing clockwise. (If nearestStormDistance is zero, then this value will not be defined.)
    let nearestStormDistance: Double?           // optional, only on currently. The approximate distance to the nearest storm in miles. (A storm distance of 0 doesn’t necessarily refer to a storm at the requested location, but rather a storm in the vicinity of that location.)
    let ozone: Double?                          // optional. The columnar density of total atmospheric ozone at the given time in Dobson units.
    let precipAccumulation: Double?             // optional, only on hourly and daily. The amount of snowfall accumulation expected to occur, in inches. (If no snowfall is expected, this property will not be defined.)
    let precipIntensity: Double?                // optional The intensity (in inches of liquid water per hour) of precipitation occurring at the given time. This value is conditional on probability (that is, assuming any precipitation occurs at all).
    let precipIntensityError: Double?           // optional. The standard deviation of the distribution of precipIntensity. (We only return this property when the full distribution, and not merely the expected mean, can be estimated with accuracy.)
    let precipIntensityMax: Double?             // optional, only on daily. The maximum value of precipIntensity during a given day.
    let precipIntensityMaxTime: Double?         // optional, only on daily. The UNIX time of when precipIntensityMax occurs during a given day.
    let precipProbability: Double?              // optional. The probability of precipitation occurring, between 0 and 1, inclusive.
    let precipType: String?                     // optional. The type of precipitation occurring at the given time. If defined, this property will have one of the following values: "rain", "snow", or "sleet" (which refers to each of freezing rain, ice pellets, and “wintery mix”). (If precipIntensity is zero, then this property will not be defined. Additionally, due to the lack of data in our sources, historical precipType information is usually estimated, rather than observed.)
    let pressure: Double?                       // optional. The sea-level air pressure in millibars.
    let sunriseTime: Double?
    let sunsetTime: Double?
    let temperature: Double?                    // optional, only on hourly. The air temperature in degrees Fahrenheit.
    let temperatureHigh: Double?                // optional, only on daily. The daytime high temperature.
    let temperatureHighTime: Double?            // optional, only on daily. The UNIX time representing when the daytime high temperature occurs.
    let temperatureLow: Double?                 // optional, only on daily. The overnight low temperature.
    let temperatureLowTime: Double?             // optional, only on daily. The UNIX time representing when the overnight low temperature occurs.
    let temperatureMax: Double?                 // optional, only on daily. The maximum temperature during a given date.
    let temperatureMaxTime: Double?             // optional, only on daily. The UNIX time representing when the maximum temperature during a given date occurs.
    let temperatureMin: Double?                 // optional, only on daily. The minimum temperature during a given date.
    let temperatureMinTime: Double?             // optional, only on daily. The UNIX time representing when the minimum temperature during a given date occurs.
    let uvIndex: Double?                        // optional. The UV index.
    let uvIndexTime: Double?                    // optional, only on daily. The UNIX time of when the maximum uvIndex occurs during a given day.
    let visibility: Double?                     // optional. The average visibility in miles, capped at 10 miles.
    let windBearing: Double?                    // optional. The direction that the wind is coming from in degrees, with true north at 0° and progressing clockwise. (If windSpeed is zero, then this value will not be defined.)
    let windGust: Double?                       // optional. The wind gust speed in miles per hour.
    let windGustTime: Double?                   // optional, only on daily. The time at which the maximum wind gust speed occurs during the day.
    let windSpeed: Double?                      // optional. The wind speed in miles per hour.
}
