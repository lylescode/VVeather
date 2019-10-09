//
//  Locator.swift
//  Yellow
//
//  Created by Lyle on 22/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

enum LocationError: Error {
    case locationNotFound
}

final class Locator: NSObject {
    enum AuthorizationError: Error {
        case denied // 위치정보를 허용하지 않은 상태
        case serviceNotEnabled
    }
    
    typealias CLLocationCompletionHandler = (Result<CLLocation, Error>) -> Void
    typealias AuthorizationCompletionHandler = (Result<CLAuthorizationStatus, Error>) -> Void
    
    static let shared = Locator()
    
    private var completionHandlers = [CLLocationCompletionHandler]()
    private var authorizationCompletionHandler: AuthorizationCompletionHandler?
    
    lazy private var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        return locationManager
    }()
    
    static var servicesEnabled: Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    // MARK: - Authorization
    static func requestAuthorization(completionHandler: AuthorizationCompletionHandler? = nil) {
        shared.requestAuthorization(completionHandler)
    }
    
    private func requestAuthorization(_ completionHandler: AuthorizationCompletionHandler? = nil) {
        if Locator.servicesEnabled {
            authorizationCompletionHandler = completionHandler
            locationManager.requestWhenInUseAuthorization()
        } else {
            completionHandler?(.failure(AuthorizationError.serviceNotEnabled))
        }
    }
    
    // MARK: - Methods
    private func locateCLLocation(completionHandler: @escaping CLLocationCompletionHandler) {
        completionHandlers.append(completionHandler)
        if CLLocationManager.authorizationStatus() == .notDetermined {
            requestAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func reset() {
        completionHandlers = []
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Static Methods
    static func locateCurrentPlacemark(completionHandler: @escaping (Result<CLPlacemark, Error>) -> Void) {
        shared.locateCLLocation { result in
            switch result {
            case .success(let location):
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                    if let error = error {
                        completionHandler(.failure(error))
                    }
                    if let placemark = placemarks?.first {
                        completionHandler(.success(placemark))
                    } else {
                        completionHandler(.failure(LocationError.locationNotFound))
                    }
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
}

// MARK: - CLLocationManagerDelegate
extension Locator: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(#function, status.rawValue)
        authorizationCompletionHandler?(.success(status))
        authorizationCompletionHandler = nil
        if !completionHandlers.isEmpty {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            completionHandlers.forEach { $0(.success(location)) }
        } else {
            completionHandlers.forEach { $0(.failure(LocationError.locationNotFound)) }
        }
        reset()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            completionHandlers.forEach { $0(.failure(error)) }
        default:
            completionHandlers.forEach { $0(.failure(AuthorizationError.denied)) }
        }
        reset()
    }
}

