//
//  OverviewViewController.swift
//  Yellow
//
//  Created by Lyle on 24/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit
class OverviewViewController: UITableViewController {
    // MARK: - Properties
    public var viewModel: WeatherViewModelType? = WeatherViewModel()
    private var presented = false
    
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
        
        viewModel?.inputs.fetchCurrentLocation()
        viewModel?.inputs.fetchLocations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Configures
    private func configureUI() {
        clearsSelectionOnViewWillAppear = false
    }
        
    // MARK: - Binding
    private func bindViewModel(_ viewModel: WeatherViewModelType) {
        viewModel.outputs.fetchLocations { [weak self] result in
            self?.tableView.reloadData()
            self?.animateInitialCells()
        }
        viewModel.outputs.didChangeLocation { [weak self] result in
            switch result.type {
            case .insert:
                guard let newIndexPath = result.newIndexPath else { return }
                self?.tableView.insertRows(at: [IndexPath(row: newIndexPath.row, section: 0)], with: .automatic)
            case .delete:
                guard let indexPath = result.indexPath else { return }
                self?.tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
            case .update:
                guard let indexPath = result.indexPath,
                    let cell = self?.tableView.cellForRow(at: IndexPath(row: indexPath.row, section: 0)) as? OverviewCell else
                { return }
                cell.updateLocation(location: result.location)
            default:
                break
            }
        }
        viewModel.outputs.updateTimes { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.visibleCells.forEach {
                    guard let overviewCell = $0 as? OverviewCell else { return }
                    overviewCell.updateTime()
                }
            }
        }
    }
    // MARK: - Animations
    private func animateInitialCells() {
        guard !presented else { return }
        presented = true
        tableView.layoutIfNeeded()
        
        let cells = tableView.visibleCells.sorted(by: { $0.frame.minY < $1.frame.minY })
        let delayIncrease = 0.015
        if cells.count > 0 {
            view.isUserInteractionEnabled = false
            let duration = 0.65
            var delay = 0.0
            for cell in cells {
                let isLastCell = (cell == cells.last)
                cell.transform = CGAffineTransform(translationX: 0, y: 800)
                cell.alpha = 0
                UIView.animate(withDuration: duration, delay: delay,
                               usingSpringWithDamping: 0.9,
                               initialSpringVelocity: 0.8,
                               options: .curveLinear,
                               animations: {
                                cell.alpha = 1
                                cell.transform = .identity
                }, completion: { finished in
                    if isLastCell {
                        self.view.isUserInteractionEnabled = true
                    }
                })
                delay += delayIncrease
            }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let locations = viewModel?.outputs.fetchedLocations.count ?? 0
        let numbersOfInSection = [locations, 1]
        return numbersOfInSection[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OverviewCell", for: indexPath) as? OverviewCell else {
                fatalError()
            }
            let weatherLocation = viewModel?.outputs.fetchedLocations[indexPath.row]
            cell.configure(indexPath: indexPath, location: weatherLocation)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OverviewOptionCell", for: indexPath) as? OverviewOptionCell else {
                fatalError()
            }
            cell.configure(unitSymbol: WeatherUnit.currentUnitSymbol)
            cell.addingButtonHandler = { [weak self] in
                self?.performSegue(withIdentifier: "SegueOverviewToSearch", sender: nil)
            }
            cell.temperatureUnitButtonHandler = { [weak self] _ in
                self?.tableView.visibleCells.forEach {
                    guard let overviewCell = $0 as? OverviewCell else { return }
                    overviewCell.updateTemperatureUnit()
                }
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel?.inputs.delete(at: indexPath.row)
            
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        viewModel?.inputs.move(from: fromIndexPath.row, to: to.row)
    }
    
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            print(#function, "indexPath : \(indexPath)")
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
                        
                        guard let index = self?.viewModel?.outputs.fetchedLocations.firstIndex(of: weatherLocation)
                        else { return }
                        self?.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: true)
                        
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
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                weatherViewController.selectedIndexPath = selectedIndexPath
            }
            
            weatherViewController.viewModel = self.viewModel
            weatherViewController.didComplete = { [weak self] indexPath in
                self?.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                
                if let cell = self?.tableView.cellForRow(at: indexPath) as? OverviewCell {
                    cell.visualView.animator.splash()
                }
                
            }
        }
    }
}

