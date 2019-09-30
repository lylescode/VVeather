//
//  WeatherDailyCell.swift
//  Yellow
//
//  Created by Lyle on 30/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

class WeatherDailyCell: UICollectionViewCell, WeatherForestResponseCellType {
    
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
        
        tableView.register(UINib(nibName: String(describing: WeatherNestedDailyCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: WeatherNestedDailyCell.self))
    }
    
    func configure(timeZone: TimeZone, forecastResponse: ForecastResponse) {
        self.timeZone = timeZone
        self.forecastResponse = forecastResponse
    }

}


// MARK: - UICollectionViewDataSource
extension WeatherDailyCell: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let daily = forecastResponse?.daily else { return 0 }
        return min(8, daily.data.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: WeatherNestedDailyCell.self), for: indexPath)
        if let cell = cell as? WeatherForecastPointTypeCell {
            if let timeZone = self.timeZone,
                let daily = forecastResponse?.daily {
                
                cell.configure(timeZone: timeZone, forecastPoint: daily.data[indexPath.item])
            }
        }
        
        return cell
    }
    
}

