//
//  HTTPMethod.swift
//  Yellow
//
//  Created by Lyle on 22/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import Foundation

public struct HTTPMethod: RawRepresentable, Equatable, Hashable {
    public static let get = HTTPMethod(rawValue: "GET")
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

