//
//  SearchLocationViewController.swift
//  Yellow
//
//  Created by Lyle on 22/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit
import MapKit

class SearchAddressViewController: UITableViewController {
    // MARK: - Properties
    public var viewModel: SearchAddressViewModelType?
    public var didComplete: ((MKLocalSearchCompletion) -> Void)?
    
    lazy private var searchBar = UISearchBar()
    var searchAddressResults: [SearchAddressResultType] {
        return viewModel?.outputs.searchAddressResults ?? []
    }
    
    deinit {
        print(Self.self, #function)
    }
    
    // MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        if let viewModel = self.viewModel {
            bindViewModel(viewModel)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - Configures
    private func configureUI() {
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.barStyle = .default
            
            if UIAccessibility.isReduceTransparencyEnabled {
                navigationController?.view.backgroundColor = .systemBackground
                tableView.backgroundColor = .systemBackground
            } else {
                navigationController?.view.backgroundColor = .clear
                tableView.backgroundColor = .clear
                
                let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                tableView.backgroundView = blurEffectView
                tableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
            }
            
        } else {
            navigationController?.navigationBar.barStyle = .black
            tableView.backgroundColor = .darkGray
        }
        
        searchBar.placeholder = "검색"
        searchBar.delegate = self
        searchBar.barStyle = .default
        searchBar.searchBarStyle = .minimal
        searchBar.textContentType = .addressCityAndState
        searchBar.showsCancelButton = false
        navigationItem.titleView = searchBar
    }
    
    // MARK: - Binding
    private func bindViewModel(_ viewModel: SearchAddressViewModelType) {
        viewModel.outputs.update { [weak self] status in
            switch status {
            case .initial, .empty, .searching:
                print("status - \(status)")
                self?.tableView.reloadData()
            case .finished(_):
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func closeButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (searchAddressResults.isEmpty) ? 1 : searchAddressResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        if !searchAddressResults.isEmpty {
            cell.textLabel?.text = searchAddressResults[indexPath.item].title
            if let ranges = searchAddressResults[indexPath.item].searchCompletion.titleHighlightRanges as? [NSRange] {
                cell.textLabel?.highlight(ranges: ranges, color: .searchResultLabel)
            }
        } else {
            cell.textLabel?.text = viewModel?.outputs.searchAddressStatus.description
            cell.textLabel?.textColor = UIColor.searchResultLabel.withAlphaComponent(0.5)
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !searchAddressResults.isEmpty else { return }
        didComplete?(searchAddressResults[indexPath.item].searchCompletion)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UISearchBarDelegate
extension SearchAddressViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel?.inputs.search(queryFragment: searchText)
    }
}
