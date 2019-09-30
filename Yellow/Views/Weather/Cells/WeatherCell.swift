//
//  WeatherCell.swift
//  Yellow
//
//  Created by Lyle on 29/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit


final class WeatherCell: UICollectionViewCell {
    private struct Constant {
        static let TopHeight: CGFloat = 400
        static let TopMinHeight: CGFloat = 130
        
        static let HourlyHeight: CGFloat = 100
        static let DailyHeight: CGFloat = 300
        static let SummaryCellHeight: CGFloat = 70
        static let TodayHeight: CGFloat = 300
    }
    
    // MARK: - Properties
    typealias WeatherCellType = [(type: UICollectionViewCell.Type, height: CGFloat)]
    private var WeatherCellTypes: [WeatherCellType] {
        if Device.horizontalSizeClass == .compact {
            return [[(type: WeatherTopCell.self, height: Constant.TopHeight)],
                    [(type: WeatherHourlyCell.self, height: Constant.HourlyHeight)],
                    [(type: WeatherDailyCell.self, height: Constant.DailyHeight)],
                    [(type: WeatherSummaryCell.self, height: Constant.SummaryCellHeight)],
                    [(type: WeatherTodayCell.self, height: Constant.TodayHeight)]]
        } else {
            return [[(type: WeatherTopCell.self, height: Constant.TopMinHeight)],
                    [(type: WeatherHourlyCell.self, height: Constant.HourlyHeight)],
                    [(type: WeatherDailyCell.self, height: Constant.DailyHeight), (type: WeatherTodayCell.self, height: Constant.TodayHeight)],
                    [(type: WeatherSummaryCell.self, height: Constant.SummaryCellHeight)]]
        }
    }
    
    private var timeZone: TimeZone?
    private var collectionView: UICollectionView?
    private var forecastResponse: ForecastResponse?
    private var weatherLocation: WeatherLocation?
    
    private var effectView: WeatherEffect?
    
    // MARK: - Lifecycles
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.timeZone = nil
        self.forecastResponse = nil
        self.weatherLocation = nil
        collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        effectView?.stop()
        effectView?.removeFromSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        reloadLayout()
    }
    
    public func reloadLayout() {
        guard let layout = collectionView?.collectionViewLayout as? WeatherCellLayout else { return }
        layout.reloadLayout()
        collectionView?.reloadData()
        
    }
    
    // MARK: - Configure
    private func configureUI() {
        backgroundColor = .clear
        
        let layout = WeatherCellLayout()
        layout.layoutDelegate = self
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = true
        collectionView.dataSource = self
        collectionView.allowsSelection = false
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        self.collectionView = collectionView
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        // Register Cells
        WeatherCellTypes.forEach { cellType in
            cellType.forEach {
                collectionView.register(UINib(nibName: String(describing: $0.type), bundle: nil),
                                        forCellWithReuseIdentifier: String(describing: $0.type))
            }
        }
    }
    
    func configure(location: WeatherLocation? = nil) {
        if let location = location {
            self.weatherLocation = location
            contentView.backgroundColor = location.isCurrentLocation ? .red : .black
            do {
                if let forecastResponse = try location.forecastResponse(),
                    let timeZone = TimeZone(identifier: forecastResponse.timezone) {
                    self.forecastResponse = forecastResponse
                    self.timeZone = timeZone
                    
                    if let temperature = WeatherUnit(temperature: forecastResponse.currently?.temperature).celsius?.value,
                        let temperatureColor = UIColor.color(from: temperature)?.adjust(hue: 0, saturation: -0.25, brightness: 0) {
                        contentView.animator.color(temperatureColor.withAlphaComponent(0.5))
                    } else {
                        contentView.animator.color(.black)
                    }
                    
                    configureEffectView()
                }
                collectionView?.reloadData()
            } catch {
                print(#function, "error \(error), \(error.localizedDescription)")
            }
        }
    }
    
    func configureEffectView() {
        
        if let icon = self.forecastResponse?.currently?.icon {
            if let weatherEffect = WeatherEffect(effect: icon) {
                weatherEffect.animator.color(UIColor.black.withAlphaComponent(0.2))
                weatherEffect.translatesAutoresizingMaskIntoConstraints = false
                contentView.insertSubview(weatherEffect, at: 0)
                NSLayoutConstraint.activate([
                    weatherEffect.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                    weatherEffect.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                    weatherEffect.topAnchor.constraint(equalTo: contentView.topAnchor),
                    weatherEffect.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                ])
                self.effectView = weatherEffect
            }
        }
        
    }
    
    // MARK: - Updates
    func updateLocation(location: WeatherLocation) {
        configure(location: location)
        contentView.animator.splash()
    }
    
}

// MARK: - UICollectionViewDataSource
extension WeatherCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return WeatherCellTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return WeatherCellTypes[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellType = WeatherCellTypes[indexPath.section][indexPath.item].type
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: cellType), for: indexPath)
        guard let location = self.weatherLocation,
            let forecastResponse = self.forecastResponse,
            let timeZone = self.timeZone else { return cell }
        
        if let cell = cell as? WeatherLocationCellType {
            cell.configure(location: location, forecastResponse: forecastResponse)
        } else if let cell = cell as? WeatherForestResponseCellType {
            cell.configure(timeZone: timeZone, forecastResponse: forecastResponse)
        }
        
        return cell
    }
    
}

extension WeatherCell: UICollectionViewDelegate {
    
}

// MARK: - WeatherCellLayoutDelegate
extension WeatherCell: WeatherCellLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldFloatSectionAt section: Int) -> Bool {
        return WeatherCellTypes[section][0].type == WeatherTopCell.self ||
        WeatherCellTypes[section][0].type == WeatherHourlyCell.self
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat {
        
        let cellType = WeatherCellTypes[indexPath.section][indexPath.item]
        
        let offsetY = collectionView.contentOffset.y
        if cellType.type == WeatherTopCell.self, offsetY < 0 {
            let height = cellType.height - offsetY
            return height
        } else {
            return cellType.height
        }
    }
}
