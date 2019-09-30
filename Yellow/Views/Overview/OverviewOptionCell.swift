//
//  OverviewOptionCell.swift
//  Yellow
//
//  Created by Lyle on 24/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

class OverviewOptionCell: UITableViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet weak var temperatureSymbolLabel: UILabel!
    
    // MARK: - Properties
    public var addingButtonHandler: (() -> Void)?
    public var temperatureUnitButtonHandler: ((String) -> Void)?
    
    // MARK: - Lifecycle
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
    
    // MARK: - IBAction
    @IBAction func addingButtonAction(_ sender: Any) {
        addingButtonHandler?()
    }
    
    @IBAction func temperatureSymbolButtonAction(_ sender: Any) {
        let unitSymbol = WeatherUnit.toggleTemperatureUnit()
        configure(unitSymbol: unitSymbol)
        temperatureUnitButtonHandler?(unitSymbol)
    }
    
}
