//
//  SearchAddressViewModel.swift
//  Yellow
//
//  Created by Lyle on 22/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import Foundation
import MapKit
import CoreData

extension SearchStatusType where ResultType == [SearchAddressResultType] {
    var description: String {
        switch self {
        case .initial: return ""
        case .searching: return "도시 확인 중..."
        case .empty: return "발견된 결과가 없습니다."
        case .finished: return ""
        }
    }
}

typealias SearchAddressResultType = (title: String, searchCompletion: MKLocalSearchCompletion)
typealias SearchAddressStatusType = SearchStatusType<[SearchAddressResultType]>
typealias SearchAddressStatusHandlerType = (SearchAddressStatusType) -> Void

protocol SearchAddressViewModelInputs {
    func search(queryFragment: String)
}

protocol SearchAddressViewModelOutputs {
    var searchAddressStatus: SearchAddressStatusType { get }
    var searchAddressResults: [SearchAddressResultType] { get }
    func update(_ updateHandler: @escaping SearchAddressStatusHandlerType)
}

protocol SearchAddressViewModelType {
    var inputs: SearchAddressViewModelInputs { get }
    var outputs: SearchAddressViewModelOutputs { get }
}

final class SearchAddressViewModel: NSObject, SearchAddressViewModelType, SearchAddressViewModelInputs, SearchAddressViewModelOutputs {
    
    var inputs: SearchAddressViewModelInputs { return self }
    var outputs: SearchAddressViewModelOutputs { return self }

    // MARK: - Properties
    lazy private var searchCompleter = MKLocalSearchCompleter()
    lazy private var dataManager = CoreDataManager<WeatherLocation>()
    lazy private var updateHandlers = [SearchAddressStatusHandlerType]()
    private var status: SearchAddressStatusType = .initial {
        willSet {
            guard newValue != status else { return }
            updateHandlers.forEach { $0(newValue) }
        }
    }
    private var results = [SearchAddressResultType]() {
        didSet {
            if results.isEmpty {
                status = searchCompleter.queryFragment.isEmpty ?
                    .initial : .empty
            } else {
                status = .finished(results)
            }
        }
    }
    
    // MARK: - Initializer
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.filterType = .locationsOnly
    }
    
    // MARK: - Inputs
    func search(queryFragment: String) {
        searchCompleter.cancel()
        searchCompleter.queryFragment = queryFragment
        if queryFragment.isEmpty {
            results.removeAll()
        } else {
            status = .searching
        }
    }
    
    // MARK: - Outputs
    var searchAddressStatus: SearchAddressStatusType {
        return status
    }
    var searchAddressResults: [SearchAddressResultType] {
        return results
    }
    func update(_ updateHandler: @escaping SearchAddressStatusHandlerType) {
        updateHandlers.append(updateHandler)
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension SearchAddressViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results.map { (title: $0.title, searchCompleter: $0) }
    }
}
