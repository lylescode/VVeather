//
//  DarkSkyAPIManager.swift
//  Yellow
//
//  Created by Lyle on 22/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import Networking

enum APIEnvironment {
    case production
    case develop
}

struct DarkSkyAPI {
    // 날씨 정보는 15분 마다 갱신되도록
    static let updateTimeInterval: TimeInterval = 60 * 15
    static let baseURL = "https://api.darksky.net"
    static let key = "9c87420e4d83e34f0d7e8fba0c272c22"
    
    @discardableResult
    static func request(location: WeatherLocation, completion: @escaping (Result<Data, Error>) -> Void) -> Router<DarkSkyAPIEndPoint> {
        request(latitude: location.latitude, longitude: location.longitude, completion: completion)
    }
    
    @discardableResult
    static func request(latitude: Double, longitude: Double, completion: @escaping (Result<Data, Error>) -> Void) -> Router<DarkSkyAPIEndPoint> {
        let router = Router<DarkSkyAPIEndPoint>()
        router.request(.forecast(latitude: String(latitude), longitude: String(longitude))) { result in
            switch result {
            case .success(let data):
                completion(.success(data))

            case .failure(let error):
                completion(.failure(error))
            }
        }
        return router
    }

    
}

