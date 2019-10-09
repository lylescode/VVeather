//
//  WeatherViewModel.swift
//  Yellow
//
//  Created by Lyle on 24/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import Foundation
import MapKit
import CoreData
import NotificationCenter


typealias LocationResultsType = [WeatherLocation]
typealias FetchLocationsHandlerType = (LocationResultsType) -> Void
typealias DidChangeLocationHandlerType = ((type: NSFetchedResultsChangeType, location: WeatherLocation, indexPath: IndexPath?, newIndexPath: IndexPath?)) -> Void

protocol WeatherViewModelInputs {
    func fetchCurrentLocation()
    func fetchLocations()
    func addLocation(from searchCompletion: MKLocalSearchCompletion, completion: ((Result<WeatherLocation, Error>) -> Void)?)
    func delete(at index: Int)
    func move(from fromIndex: Int, to toIndex: Int)
}

protocol WeatherViewModelOutputs {
    var locations: LocationResultsType { get }
    func updateTimes(_ updatehandler: @escaping () -> Void)
    func fetchLocations(_ updateHandler: @escaping FetchLocationsHandlerType)
    func didChangeLocation(_ updateHandler: @escaping DidChangeLocationHandlerType)
    
}

protocol WeatherViewModelType {
    var inputs: WeatherViewModelInputs { get }
    var outputs: WeatherViewModelOutputs { get }
}

final class WeatherViewModel: NSObject, WeatherViewModelType, WeatherViewModelInputs, WeatherViewModelOutputs {
    var inputs: WeatherViewModelInputs { return self }
    var outputs: WeatherViewModelOutputs { return self }
    
    // MARK: - Properties
    lazy private var dataManager = CoreDataManager<WeatherLocation>()
    lazy private var fetchedResultsController: NSFetchedResultsController<WeatherLocation> = {
        let fetchedResultsController = dataManager.fetchedResultsController()
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    lazy private var forecastUpdateTimers: [String: Timer] = [:]
    lazy private var timeUpdateHandlers: [() -> Void] = []
    lazy private var locationUpdateHandlers: [FetchLocationsHandlerType] = []
    lazy private var locationChangeHandlers: [DidChangeLocationHandlerType] = []
    
    private var timerInterval: TimeInterval = 1
    private enum TimerState {
        case suspended
        case resumed
    }
    private var timerState: TimerState = .suspended {
        willSet {
            guard newValue != timerState else { return }
            switch newValue {
            case .suspended:
                timer.suspend()
            case .resumed:
                timer.resume()
            }
        }
    }
    private lazy var timer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now(), repeating: .seconds(Int(timerInterval)))
        timer.setEventHandler(handler: { [weak self] in
            self?.timeUpdateHandlers.forEach { $0() }
        })
        return timer
    }()
    
    // MARK: - Initializer
    override init() {
        super.init()

        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil, using: { [weak self] _ in
            self?.fetchCurrentLocation()
            self?.locations.forEach { self?.updateForecastIfNeeded(location: $0) }
        })
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        timerState = .suspended
        for (_, scheduledTimer) in forecastUpdateTimers {
            scheduledTimer.invalidate()
        }
        forecastUpdateTimers.removeAll()
        print(Self.self, #function)
    }
    
    // MARK: - Methods
    private func updateForecastIfNeeded(location: WeatherLocation) {
        let timeIntervalSinceNow = location.forecastUpdatedDate?.timeIntervalSinceNow.magnitude ?? DarkSkyAPI.updateTimeInterval
        if  DarkSkyAPI.updateTimeInterval <= timeIntervalSinceNow {
            updateForecast(location: location)
        } else {
            scheduledUpdateForecast(location: location, timeInterval: DarkSkyAPI.updateTimeInterval - timeIntervalSinceNow)
        }
    }
    
    private func updateForecast(location: WeatherLocation) {
        guard !location.isForecastUpdating else { return }
        location.isForecastUpdating = true
        print(#function, " ------------------- name: \(location.name), date: \(Date())")
        DarkSkyAPI.request(location: location) { [weak self] result in
            switch result {
            case .success(let responseData):
                location.forecastUpdatedDate = Date()
                location.forecastResponseData = responseData
                
            case .failure(let error):
                location.forecastUpdatedDate = nil
                location.forecastResponseData = nil
                print(#function, "error : \(error) - \(error.localizedDescription)")
            }
            location.isForecastUpdating = false
            self?.dataManager.saveContext()
            
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.scheduledUpdateForecast(location: location, timeInterval: DarkSkyAPI.updateTimeInterval)
            }
        }
    }
    
    private func scheduledUpdateForecast(location: WeatherLocation, timeInterval: TimeInterval) {
        cancelScheduledUpdateForecast(location: location)
        let timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block: { [weak self] _ in
            self?.updateForecastIfNeeded(location: location)
        })
        forecastUpdateTimers[location.name] = timer
        //print(#function, "location.name : \(location.name), timeInterval : \(timeInterval)")
    }
    private func cancelScheduledUpdateForecast(location: WeatherLocation) {
        forecastUpdateTimers[location.name]?.invalidate()
        //print(#function, "location.name : \(location.name)")
    }
    
    // MARK: - Inputs
    func fetchCurrentLocation() {
        Locator.locateCurrentPlacemark { [weak self] result in
            switch result {
            case .success(let placemark):
                self?.dataManager.addCurrentLocation(from: placemark) { result in
                    switch result {
                    case .success(let location):
                        self?.updateForecastIfNeeded(location: location)
                    case .failure(let error):
                        print("addCurrentLocation error : \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                // TODO: AuthorizationError일 때 허용하도록 Alert 띄우기
                print("locateCurrentLocation error : \(error.localizedDescription)")
            }
        }
    }
    
    func fetchLocations() {
        do {
            try fetchedResultsController.performFetch()
            guard let fetchedObjects = fetchedResultsController.fetchedObjects else {
                fatalError()
            }
            locationUpdateHandlers.forEach { $0(fetchedObjects) }
            fetchedObjects.forEach { updateForecastIfNeeded(location: $0) }
        } catch {
            fatalError()
        }
    }
    
    func addLocation(from searchCompletion: MKLocalSearchCompletion, completion: ((Result<WeatherLocation, Error>) -> Void)?) {
        
        let request = MKLocalSearch.Request(completion: searchCompletion)
        let localSearch = MKLocalSearch(request: request)
        
        Application.isNetworkActivityIndicatorVisible = true
        localSearch.start { [weak self] (response, error) in
            Application.isNetworkActivityIndicatorVisible = false
            if let error = error {
                completion?(.failure(error))
            } else if let mapItem = response?.mapItems.first {
                self?.dataManager.addLocation(from: mapItem.placemark) { result in
                    switch result {
                    case .success(let weatherLocation):
                        completion?(.success(weatherLocation))
                    case .failure(let error):
                        completion?(.failure(error))
                    }
                }
            } else {
                completion?(.failure(LocationError.locationNotFound))
            }
        }
    }
    
    
    func delete(at index: Int) {
        dataManager.delete(fetchedResultsController, at: index)
    }
    
    func move(from fromIndex: Int, to toIndex: Int) {
        dataManager.move(fetchedResultsController, from: fromIndex, to: toIndex)
    }
    
    // MARK: - Outputs
    var locations: LocationResultsType {
        return fetchedResultsController.fetchedObjects ?? []
    }
    func updateTimes(_ updatehandler: @escaping () -> Void) {
        timerState = .resumed
        timeUpdateHandlers.append(updatehandler)
    }
    func fetchLocations(_ updateHandler: @escaping FetchLocationsHandlerType) {
        locationUpdateHandlers.append(updateHandler)
    }
    func didChangeLocation(_ updateHandler: @escaping DidChangeLocationHandlerType) {
        locationChangeHandlers.append(updateHandler)
    }
    
}

extension WeatherViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //guard let weatherLocations = controller.fetchedObjects as? [WeatherLocation] else { fatalError() }
        //print(#function, "weatherLocations : \(weatherLocations.count)")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let location = anObject as? WeatherLocation else { return }
        //print(#function, "type: \(type.typeString),", "name: \(location.name),", "indexPath: \(String(describing: indexPath)),", "newIndexPath: \(String(describing: newIndexPath))")
        if type == .delete {
            cancelScheduledUpdateForecast(location: location)
        } else if type == .insert {
            updateForecastIfNeeded(location: location)
        }
        locationChangeHandlers.forEach { $0((type: type, location:location, indexPath: indexPath, newIndexPath: newIndexPath)) }
    }
}

