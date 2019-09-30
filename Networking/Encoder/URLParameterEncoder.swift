//
//  URLParameterEncoder.swift
//  Yellow
//
//  Created by Lyle on 22/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import Foundation


public struct URLParameterEncoder: ParameterEncoder {
    
    public static func encode(request: inout URLRequest, parameters: Parameters) throws {
        guard let url = request.url else { throw NetworkingError.invalidURL }
        if var components = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
            components.queryItems = []
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
                components.queryItems?.append(queryItem)
            }
            request.url = components.url
        }
    }
}

