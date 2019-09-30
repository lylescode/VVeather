//
//  WeatherTodayCell.swift
//  Yellow
//
//  Created by Lyle on 30/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

class WeatherTodayCell: UICollectionViewCell, WeatherForestResponseCellType {
    
    lazy var cellTypes: [[WeatherNestedTodayCell.TodayCellType]] = [[.Sunrise, .Sunset],
                                             [.PrecipProbability, .Humidity],
                                             [.Wind, .ApparentTemperature],
                                             [.PrecipIntensity, .Pressure],
                                             [.Visibility, .UVndex]]
    
    @IBOutlet weak var tableView: UITableView!
    
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
    }
    
    private func configureUI() {
        
        tableView.register(UINib(nibName: String(describing: WeatherNestedTodayCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: WeatherNestedTodayCell.self))
    }
    
    func configure(timeZone: TimeZone, forecastResponse: ForecastResponse) {
        self.timeZone = timeZone
        self.forecastResponse = forecastResponse
    }
    
}


// MARK: - UICollectionViewDataSource
extension WeatherTodayCell: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: WeatherNestedTodayCell.self), for: indexPath)
        if let cell = cell as? WeatherNestedTodayCell {
            if let timeZone = self.timeZone,
                let forecastResponse = forecastResponse {
                
                cell.configure(cellTypes: cellTypes[indexPath.row], timeZone: timeZone, forecastResponse: forecastResponse)
            }
        }
        
        return cell
    }
    
}

