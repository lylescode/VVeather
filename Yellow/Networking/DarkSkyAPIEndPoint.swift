//
//  DarkSkyAPIEndPoint.swift
//  Yellow
//
//  Created by Lyle on 22/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import Networking

enum DarkSkyAPIEndPoint {
    case forecast(latitude: String, longitude: String)
    case test
}

extension DarkSkyAPIEndPoint: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: DarkSkyAPI.baseURL) else { fatalError() }
        return url
    }
    var httpMethod: HTTPMethod {
        return .get
    }
    var path: String {
        switch self {
        case .forecast(let latitude, let longitude):
            return "/forecast/\(DarkSkyAPI.key)/\(latitude),\(longitude)"
        case .test:
            return "/forecast/\(DarkSkyAPI.key)/42.3601,-71.0589"
        }
    }
    var task: HTTPTask {
        switch self {
        case .forecast( _, _):
            return .requestParameters(urlParameters: ["lang": Locale.current.languageCode ?? "en",
                                                 "exclude": "minutely,alerts,flags",
                                                 "units": "si"])
        default:
            return .request
        }
    }
}

