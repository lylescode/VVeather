//
//  UIColorExtension.swift
//  Yellow
//
//  Created by Lyle on 22/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

extension UIColor {
    static func color(from temperature: Double) -> UIColor? {
        guard let image = UIImage(named: "temperatureColor"),
            let cgImage = image.cgImage
            else { return nil }
        
        let normalizedTemperature = CGFloat(min(max(temperature + 50, 0), 80))
        let x = CGFloat((normalizedTemperature / 80) * (image.size.width - 2)) + 1
        let y = CGFloat(image.size.height * 0.5)
        let width = cgImage.width
        let height = cgImage.height
        
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        var color: UIColor? = nil

        if let context = context {
            context.translateBy(x: -x, y: -y)
            let rect = CGRect(x: 0, y: 0, width: width, height: height)
            context.draw(cgImage, in: rect)

            color = UIColor(red: CGFloat(pixel[0])/255.0,
                            green: CGFloat(pixel[1])/255.0,
                            blue: CGFloat(pixel[2])/255.0,
                            alpha: CGFloat(pixel[3])/255.0)

            pixel.deallocate()
        }
        return color
    }
}

extension UIColor {
    func adjust(hue: CGFloat, saturation: CGFloat, brightness: CGFloat) -> UIColor {

        var currentHue: CGFloat = 0.0
        var currentSaturation: CGFloat = 0.0
        var currentBrigthness: CGFloat = 0.0
        var currentAlpha: CGFloat = 0.0

        if getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentAlpha) {
            return UIColor(hue: currentHue + hue,
                           saturation: currentSaturation + saturation,
                           brightness: currentBrigthness + brightness,
                           alpha: currentAlpha)
        } else {
            return self
        }
    }
}


