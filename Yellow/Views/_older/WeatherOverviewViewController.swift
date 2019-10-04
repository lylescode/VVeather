//
//  WeatherOverviewViewController.swift
//  Yellow
//
//  Created by Lyle on 30/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class WeatherOverviewViewController: UICollectionViewController {
    // MARK: - Properties
    public var viewModel: WeatherViewModelType? = WeatherViewModel()
    
    deinit {
        print(Self.self, #function)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
        if let viewModel = self.viewModel {
            bindViewModel(viewModel)
        }
        
        viewModel?.inputs.fetchCurrentLocation()
        viewModel?.inputs.fetchLocations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //reloadLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reloadLayout()
    }
    
    private func reloadLayout() {
        guard let layout = collectionView?.collectionViewLayout as? WeatherOverviewCollectionViewLayout else { return }
        layout.reloadLayout()
    }
    
    // MARK: - Configures
    private func configure() {
        clearsSelectionOnViewWillAppear = false
        
        let collectionViewLayout = WeatherOverviewCollectionViewLayout()
        collectionViewLayout.layoutDelegate = self
        
        collectionView.setCollectionViewLayout(collectionViewLayout, animated: false)
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = true
        collectionView.delaysContentTouches = false
    }
    
    // MARK: - Binding
    private func bindViewModel(_ viewModel: WeatherViewModelType) {
        viewModel.outputs.fetchLocations { [weak self] result in
            self?.collectionView.reloadData()
        }
        viewModel.outputs.didChangeLocation { [weak self] result in
            switch result.type {
            case .insert:
                guard let newIndexPath = result.newIndexPath else { return }
                self?.collectionView.insertItems(at: [IndexPath(row: newIndexPath.row, section: 0)])
            case .delete:
                guard let indexPath = result.indexPath else { return }
                self?.collectionView.deleteItems(at: [IndexPath(row: indexPath.row, section: 0)])
            case .update:
                guard let indexPath = result.indexPath,
                    let cell = self?.collectionView.cellForItem(at: IndexPath(row: indexPath.row, section: 0)) as? WeatherOverviewCell else
                { return }
                
                cell.updateLocation(location: result.location)
            default:
                break
            }
        }
        viewModel.outputs.updateTimes { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.visibleCells.forEach {
                    guard let overviewCell = $0 as? WeatherOverviewCell else { return }
                    overviewCell.updateTime()
                }
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let locations = viewModel?.outputs.locations.count ?? 0
        let numbersOfInSection = [locations, 1]
        return numbersOfInSection[section]
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WeatherOverviewCell.self), for: indexPath) as! WeatherOverviewCell
            
            let weatherLocation = viewModel?.outputs.locations[indexPath.row]
            cell.configure(indexPath: indexPath, location: weatherLocation)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WeatherOverviewOptionCell.self), for: indexPath) as! WeatherOverviewOptionCell
            
            cell.configure(unitSymbol: WeatherUnit.currentUnitSymbol)
            cell.addingButtonHandler = { [weak self] in
                self?.performSegue(withIdentifier: "SegueOverviewToSearch", sender: nil)
            }
            cell.temperatureUnitButtonHandler = { [weak self] _ in
                self?.collectionView.visibleCells.forEach {
                    guard let overviewCell = $0 as? WeatherOverviewCell else { return }
                    overviewCell.updateTemperatureUnit()
                }
            }
            return cell
        }
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            performSegue(withIdentifier: "SegueOverviewToWeather", sender: nil)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueOverviewToSearch" {
            guard let navigationController = segue.destination as? UINavigationController,
                let searchAddressViewController = navigationController.topViewController as? SearchAddressViewController else {
                    fatalError("storyboard mis configuration")
            }
            searchAddressViewController.viewModel = SearchAddressViewModel()
            searchAddressViewController.didComplete = { [weak self] searchCompletion in
                self?.viewModel?.inputs.addLocation(from: searchCompletion) { [weak self] result in
                    switch result {
                    case .success(let weatherLocation):
                        
                        guard let index = self?.viewModel?.outputs.locations.firstIndex(of: weatherLocation)
                        else { return }
                        self?.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredVertically, animated: true)
                        
                        print("Saved - \(String(describing: weatherLocation.name))")
                    case .failure(let error):
                        print("Save Erre- \(error.localizedDescription)")
                    }
                }
            }
        } else if segue.identifier == "SegueOverviewToWeather" {
            guard let weatherViewController = segue.destination as? WeatherViewController else {
                fatalError("storyboard mis configuration")
            }
            
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                weatherViewController.selectedIndexPath = selectedIndexPath
            }
            weatherViewController.viewModel = self.viewModel
            weatherViewController.didComplete = { [weak self] indexPath in
                self?.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                
                if let cell = self?.collectionView.cellForItem(at: indexPath) as? WeatherOverviewCell {
                    cell.visualView.animator.splash()
                }
                
            }
        }
    }
}

extension WeatherOverviewViewController: WeatherOverviewCollectionViewLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, relativeHeightForItemAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        if indexPath.item < collectionView.numberOfItems(inSection: 0) - 2 {
            return 45
        } else {
            return 84
        }
    }
}
