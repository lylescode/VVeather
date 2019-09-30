//
//  WeatherEffect.swift
//  Yellow
//
//  Created by Lyle on 01/10/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

enum FlakeEmitterStyle {
    case blizzard
    case rain
}
extension FlakeEmitterStyle {
    var content: CGImage? {
        switch self {
        case .blizzard:
            let contentNames = ["large1", "large2", "large3", "medium1", "medium2", "medium3", "small1", "small2", "small3", "medium1", "medium2", "medium3", "small1", "small2", "small3"]
            let contentIndex = Int.random(in: 0...contentNames.count-1)
            let contentName = contentNames[contentIndex]
            if let image = UIImage(named: contentName),
                let filter = CIFilter(name: "CIMotionBlur") {
                let cgImage = CIImage(cgImage: image.cgImage!)
                
                filter.setDefaults()
                filter.setValue(cgImage, forKey: kCIInputImageKey)
                let radius = CGFloat.random(in: 0...15)
                filter.setValue(radius, forKey: kCIInputRadiusKey)
                let angle = CGFloat.random(in: 0...360).degreesToRadians
                filter.setValue(angle, forKey: kCIInputAngleKey)
                
                let context = CIContext(options: nil)
                let imageRef = context.createCGImage(filter.outputImage!, from: cgImage.extent)
                return imageRef
            }
            return nil
        case .rain:
            return UIImage(color: UIColor(white: 0.8, alpha: CGFloat.random(in: 0.3...0.9)),
                           size: CGSize(width: CGFloat.random(in: 0.5...1.5), height: CGFloat.random(in: 20...120)))?.cgImage
        }
            
    }
    
    var count: Int {
        switch self {
        case .blizzard:
            return 22
        case .rain:
            return 33
        default:
            return 1
        }
    }
    
    var velocities: [Int] {
        switch self {
        case .blizzard:
            return [Int.random(in: 300...700)]
        case .rain:
            return [Int.random(in: 500...2000)]
        default:
            return [100, 90, 150, 200]
        }
    }
    
    var colors: [UIColor] {
        switch self {
        case .blizzard:
            return [UIColor(red: 0.95, green: 0.95, blue: 1, alpha: 1)]
        case .rain:
            return [UIColor(white: 1, alpha: 0.5)]
        default:
            return [UIColor(red: 250/255.0, green: 232/255.0, blue: 150/255.0, alpha: 1)]
        }
    }
    
    var randomVelocity: Int {
        return velocities.shuffled().first ?? 0
    }
    
    var randomColor: UIColor? {
        let color = colors.shuffled().first
        return color
    }
    
    var emitterLifetime: Float {
        switch self {
        case .blizzard:
            return 1
        case .rain:
            return 4
        }
    }
    
    var emitterShape: CAEmitterLayerEmitterShape {
        switch self {
        case .blizzard:
            return .line
        case .rain:
            return .line
        }
    }
    
    func emitterSize(withSize layerSize: CGSize) -> CGSize {
        switch self {
        case .blizzard:
            return CGSize(width: layerSize.width, height: 1)
        case .rain:
            return CGSize(width: layerSize.width, height: 1)
        }
    }
    
    func emitterPosition(withSize layerSize: CGSize) -> CGPoint {
        switch self {
        case .blizzard:
            return CGPoint(x: layerSize.width / 2, y: -40)
        case .rain:
            return CGPoint(x: layerSize.width / 2, y: -40)
        }
    }
}

class WeatherEffect: UIView {
    fileprivate let emitterLayer = CAEmitterLayer()
    fileprivate var emitterStyle: FlakeEmitterStyle = .rain
    // MARK: - Initializers
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(frame: CGRect, style: FlakeEmitterStyle) {
        self.init(frame: frame)
        emitterStyle = style
        
        isUserInteractionEnabled = false
        setupLayer()
        setupEmitterLayer()
        
        layer.addSublayer(emitterLayer)
    }
    
    convenience init?(effect: String) {
        self.init(frame: .zero)
        if effect == "sleet" || effect == "snow" {
            emitterStyle = .blizzard
        } else if effect == "rain" {
            emitterStyle = .rain
        } else {
            return nil
        }
        isUserInteractionEnabled = false
        setupLayer()
        setupEmitterLayer()
        
        layer.addSublayer(emitterLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        emitterLayer.frame = bounds
        layoutEmitterLayer()
    }
    
    fileprivate func layoutEmitterLayer() {
        emitterLayer.emitterSize = emitterStyle.emitterSize(withSize: bounds.size)
        emitterLayer.emitterPosition = emitterStyle.emitterPosition(withSize: bounds.size)
        emitterLayer.emitterShape = emitterStyle.emitterShape
    }
    
    fileprivate func setupLayer() {
        layer.backgroundColor = UIColor.clear.cgColor
    }
    
    fileprivate func setupEmitterLayer() {
        layoutEmitterLayer()
        
        emitterLayer.seed = UInt32(Date().timeIntervalSince1970)
        emitterLayer.drawsAsynchronously = true
        
        emitterLayer.emitterCells = emitterCells()
    }
    
    func stop() {
        emitterLayer.lifetime = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            self.emitterLayer.removeFromSuperlayer()
            self.removeFromSuperview()
        }
    }
    
    fileprivate func emitterCells() -> [CAEmitterCell] {
        var cells: [CAEmitterCell] = []
        let count = emitterStyle.count
        for _ in 0..<count {
            cells.append(emitterCell())
            
        }
        return cells
    }
    
    fileprivate func emitterCell() -> CAEmitterCell {
        
        let cell = CAEmitterCell()
        cell.contents = emitterStyle.content
        cell.beginTime = CACurrentMediaTime()
        
        switch emitterStyle {
        default:
            cell.color = emitterStyle.randomColor?.cgColor
        }
        cell.velocity = CGFloat(emitterStyle.randomVelocity)
        cell.velocityRange = 100
        
        switch emitterStyle {
        case .blizzard:
            cell.birthRate = 8.5
            cell.lifetime = 4
            
            cell.alphaRange = 1
            cell.alphaSpeed = -0.3
            cell.scale = 0.12
            cell.scaleRange = 0.4
            cell.scaleSpeed = -0.01
            cell.spin = CGFloat.random(in: -180...180).degreesToRadians // 초기 회전 값
            cell.spinRange = CGFloat.random(in: -180...180).degreesToRadians
            
            cell.emissionRange = 35.degreesToRadians
            cell.emissionLongitude = 180.degreesToRadians
            cell.xAcceleration = CGFloat.random(in: -200...700)
            cell.yAcceleration = -CGFloat.random(in: 10...220)
        case .rain:
            cell.birthRate = 9
            cell.lifetime = 10
            
            cell.alphaRange = 0.5
            cell.alphaSpeed = -0.1
            cell.scale = 0.2
            cell.scaleRange = 0.1
            cell.scaleSpeed = 0
            cell.spin = 0 // 초기 회전 값
            cell.spinRange = 0
            cell.emissionRange = 0
            cell.emissionLongitude = 180.degreesToRadians
            cell.yAcceleration = CGFloat.random(in: 2000...4000)
        }
        return cell
    }
}
