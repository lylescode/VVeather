//
//  Application.swift
//  Yellow
//
//  Created by Lyle on 24/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

struct Application {
    static var isNetworkActivityIndicatorVisible: Bool {
        set {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = newValue
            }
        }
        get {
            return UIApplication.shared.isNetworkActivityIndicatorVisible
        }
    }
}
