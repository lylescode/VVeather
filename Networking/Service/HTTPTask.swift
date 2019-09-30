//
//  HTTPTask.swift
//  Yellow
//
//  Created by Lyle on 22/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import Foundation

public enum HTTPTask {
    case request
    case requestParameters(urlParameters: Parameters)
}

