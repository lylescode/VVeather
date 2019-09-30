//
//  SearchStatusType.swift
//  Yellow
//
//  Created by Lyle on 27/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import Foundation

enum SearchStatusType<ResultType>: Equatable {
    case initial
    case searching
    case empty
    case finished(_ result: ResultType)
    
    private var rawValue: Int {
        switch self {
        case .initial: return 0
        case .searching: return 1
        case .empty: return 2
        case .finished: return 3
        }
    }
    static func == (lhs: SearchStatusType<ResultType>, rhs: SearchStatusType<ResultType>) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
