//
//  WeatherSummaryCell.swift
//  Yellow
//
//  Created by Lyle on 30/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

class WeatherSummaryCell: UICollectionViewCell, WeatherForestResponseCellType {
    

    @IBOutlet weak var summaryLabl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        summaryLabl.text = ""
    }
    
    func configure(timeZone: TimeZone, forecastResponse: ForecastResponse) {
        let forecastDaily = forecastResponse.daily
        summaryLabl.text = forecastDaily?.summary
    }
}
