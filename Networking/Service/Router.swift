//
//  Router.swift
//  Yellow
//
//  Created by Lyle on 22/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import Foundation

public class Router<EndPoint: EndPointType> {
    private var task: URLSessionTask?
    
    public init() {}
    public func request(_ route: EndPoint, completion: @escaping (Result<Data, Error>) -> Void) {
        let session = URLSession.shared
        do {
            let request = try build(from: route)
            task = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let response = response as? HTTPURLResponse, let data = data {
                    do {
                        try ResponseError.validating(response)
                        completion(.success(data))
                    } catch(let error) {
                        print("response - \(response)")
                        completion(.failure(error))
                    }
                }
            }
        } catch (let error) {
            completion(.failure(error))
        }
        task?.resume()
    }
    
    public func cancel() {
        task?.cancel()
    }
    
    private func build(from route: EndPoint) throws -> URLRequest {
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10.0)
        
        request.httpMethod = route.httpMethod.rawValue
        do {
            switch route.task {
            case .request:
                return request
            case .requestParameters(let urlParameters):
                try configure(urlParameters: urlParameters, request: &request)
            }
            return request
        } catch {
            throw error
        }
    }
    
    private func configure(urlParameters: Parameters, request: inout URLRequest) throws {
        do {
            try URLParameterEncoder.encode(request: &request, parameters: urlParameters)
        } catch {
            throw error
        }
    }
}
