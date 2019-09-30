//
//  WeatherOverviewOptionCell.swift
//  Yellow
//
//  Created by Lyle on 30/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

class WeatherOverviewOptionCell: UICollectionViewCell {
    
    // MARK: - Properties
    @IBOutlet weak var temperatureSymbolLabel: UILabel!
    public var addingButtonHandler: (() -> Void)?
    public var temperatureUnitButtonHandler: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Configure
    func configure(unitSymbol: String) {
        let unitString = "\(WeatherUnit.celsiusSymbol) / \(WeatherUnit.fahrenheitSymbol)"
        temperatureSymbolLabel.text = unitString
        temperatureSymbolLabel.highlight(string: unitSymbol)
    }
    
    @IBAction func addingButtonAction(_ sender: Any) {
        addingButtonHandler?()
    }
    @IBAction func temperatureSymbolButtonAction(_ sender: Any) {
        let unitSymbol = WeatherUnit.toggleTemperatureUnit()
        configure(unitSymbol: unitSymbol)
        temperatureUnitButtonHandler?(unitSymbol)
    }
    
}
