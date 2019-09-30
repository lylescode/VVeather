//
//  ForecastBlock.swift
//  Yellow
//
//  Created by Lyle on 22/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import Foundation

struct ForecastBlock: Decodable {
    // MARK: - Properties
    let summary: String?
    let icon: String?
    let data: [ForecastPoint]
}
