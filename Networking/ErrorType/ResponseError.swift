//
//  ResponseError.swift
//  Networking
//
//  Created by Lyle on 27/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import Foundation

enum ResponseError: Error {
    case clientError(_ statusCode: Int)
    case serverError(_ statusCode: Int)
    case unknown(_ statusCode: Int)
}

extension ResponseError {
    
    static func validating(_ response: HTTPURLResponse) throws {
        let statusCode = response.statusCode
        switch statusCode {
        case 200...299:
            return
        case 400...499:
            throw ResponseError.clientError(statusCode)
        case 501...599:
            throw ResponseError.serverError(statusCode)
        default:
            throw ResponseError.unknown(statusCode)
        }
    }
}
