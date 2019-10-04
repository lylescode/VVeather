//
//  WeatherViewController.swift
//  Yellow
//
//  Created by Lyle on 29/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: - Properties
    public var viewModel: WeatherViewModelType?
    public var selectedIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    public var didComplete: ((IndexPath) -> Void)?
    
    // MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        if let viewModel = self.viewModel {
            bindViewModel(viewModel)
        }
        viewModel?.inputs.fetchLocations()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        reloadLayout()
    }
    
    private func reloadLayout() {
        guard let layout = collectionView?.collectionViewLayout as? WeatherCollectionViewLayout else { return }
        layout.reloadLayout()
    }
    
    // MARK: - Configures
    private func configure() {
        let collectionViewLayout = WeatherCollectionViewLayout()
        collectionViewLayout.layoutDelegate = self
        collectionViewLayout.currentPage = selectedIndexPath.item
        
        collectionView.setCollectionViewLayout(collectionViewLayout, animated: false)
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = true
        collectionView.allowsSelection = false
        collectionView.showsHorizontalScrollIndicator = false
        
        pageControl.isUserInteractionEnabled = false
    }
    
    // MARK: - Binding
    private func bindViewModel(_ viewModel: WeatherViewModelType) {
        
        viewModel.outputs.fetchLocations { [weak self] locations in
            self?.pageControl.numberOfPages = locations.count
            self?.pageControl.currentPage = 0
            self?.collectionView.reloadData()
        }
        viewModel.outputs.didChangeLocation { [weak self] result in
            switch result.type {
            case .update:
                guard let indexPath = result.indexPath,
                    let cell = self?.collectionView.cellForItem(at: IndexPath(row: indexPath.row, section: 0)) as? WeatherCell else
                { return }
                
                cell.updateLocation(location: result.location)
            default:
                break
            }
        }
    }
    
    // MARK: - IBAction
    @IBAction func infoButtonAction(_ sender: Any) {
    }
    
    @IBAction func dismissButtonAction(_ sender: Any) {
        didComplete?(selectedIndexPath)
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UICollectionViewDataSource
extension WeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.outputs.locations.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WeatherCell.self), for: indexPath) as! WeatherCell
        let weatherLocation = viewModel?.outputs.locations[indexPath.row]
        cell.configure(location: weatherLocation)
        return cell
    }
}

// MARK: - WeatherCollectionViewLayoutDelegate
extension WeatherViewController: WeatherCollectionViewLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, fractionInteraction fraction: CGFloat, forItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, currentPage: Int) {
        pageControl.currentPage = currentPage
        selectedIndexPath = IndexPath(item: currentPage, section: 0)
    }
    
}
