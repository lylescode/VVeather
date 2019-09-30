//
//  UIColorCustom.swift
//  Yellow
//
//  Created by Lyle on 25/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

extension UIColor {
    // MARK: - Label Colors
    static var searchResultLabel: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .darkText
        }
    }
}
