//
//  WeatherHourlyCell.swift
//  Yellow
//
//  Created by Lyle on 30/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

class WeatherHourlyCell: UICollectionViewCell, WeatherForestResponseCellType {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    private var timeZone: TimeZone?
    private var forecastResponse: ForecastResponse?
    
    // MARK: - Lifecycles
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.timeZone = nil
        self.forecastResponse = nil
        
        collectionView.setContentOffset(.zero, animated: false)
    }
    
    private func configureUI() {
        collectionView.register(UINib(nibName: String(describing: WeatherNestedHourlyCell.self), bundle: nil),
                                forCellWithReuseIdentifier: String(describing: WeatherNestedHourlyCell.self))
    }
    
    func configure(timeZone: TimeZone, forecastResponse: ForecastResponse) {
        self.timeZone = timeZone
        self.forecastResponse = forecastResponse
    }
}

// MARK: - UICollectionViewDataSource
extension WeatherHourlyCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let hourly = forecastResponse?.hourly else { return 0 }
        return hourly.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WeatherNestedHourlyCell.self), for: indexPath)
        
        if let cell = cell as? WeatherForecastPointTypeCell {
            if let timeZone = self.timeZone,
                let hourly = forecastResponse?.hourly {
                
                cell.configure(timeZone: timeZone, forecastPoint: hourly.data[indexPath.item])
            }
        }
        
        return cell
    }
    
}

