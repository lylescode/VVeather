//
//  Device.swift
//  Yellow
//
//  Created by Lyle on 24/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

enum Device {
    static var window: UIWindow {
        let window = UIApplication.shared.delegate?.window ?? UIApplication.shared.keyWindow
        assert(window != nil, "keyWindow not found")
        return window!
    }
    static var safeAreaTop: CGFloat {
        return window.safeAreaInsets.top
    }
    static var safeAreaBottom: CGFloat {
        return window.safeAreaInsets.bottom
    }
    static var horizontalSizeClass: UIUserInterfaceSizeClass {
        return window.traitCollection.horizontalSizeClass
    }
    static var verticalSizeClass: UIUserInterfaceSizeClass {
        return window.traitCollection.verticalSizeClass
    }
}
