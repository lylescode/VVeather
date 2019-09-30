//
//  UIViewExtension.swift
//  Yellow
//
//  Created by Lyle on 24/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

// MARK: - Style
extension UILabel {
    @IBInspectable var isShadowLabel: Bool {
        get { return self.isShadowLabel }
        set {
            if newValue {
                layer.shadowColor = self.textColor.cgColor
                layer.shadowRadius = 3
                layer.shadowOpacity = 0.17
                layer.shadowOffset = CGSize(width: 0, height: 2)
                layer.masksToBounds = false
            } else {
                layer.shadowColor = UIColor.clear.cgColor
                layer.shadowRadius = 0
                layer.shadowOpacity = 0
                layer.shadowOffset = .zero
            }
        }
    }
}

// MARK: - AttributedText
extension UILabel {
    func highlight(string: String, color: UIColor? = nil) {
        let fullString = NSString(string: text ?? "")
        let range = fullString.range(of: string)
        highlight(ranges: [range])
    }
    
    func highlight(ranges: [NSRange], color: UIColor? = nil) {
        guard let text = self.text, let textColor = self.textColor else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.alignment = textAlignment
        
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[.font] = font
        attributes[.foregroundColor] = textColor.withAlphaComponent(0.5)
        attributes[.paragraphStyle] = paragraphStyle
        
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes(attributes, range: NSRange(location: 0, length: attributedText.length))
        
        ranges.forEach { attributedText.addAttribute(.foregroundColor, value: color ?? textColor, range: $0) }
        
        self.attributedText = attributedText
    }
}
