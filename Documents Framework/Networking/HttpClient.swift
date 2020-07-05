//
//  NetworkingService.swift
//  LoopInNormalMode
//
//  Created by Assaf Tayouri on 02/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation
public class HttpClient {    
    public func request(url: String, method: String = "POST",  queryParam: [String: String]? = nil,  body: /*[AnyHashable: Any]*/Encodable? = nil,
                        headers: [String:String] = [:]) throws -> Data? {
        var urlComponents = URLComponents(string: url)!
        
        if let queryParam = queryParam {
            urlComponents.queryItems = queryParam.map {
                URLQueryItem(name: $0, value: $1)
            }
        }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = method
        
        headers.forEach {
            request.addValue($1, forHTTPHeaderField: $0)
        }
        
        if let body = body {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response, error) = URLSession.shared.performSynchronously(request: request)
        
        if let error = error {
            switch error.errorCode {
            case -1001:
                throw HttpError.requestTimedOutError(message: "Request timed out")
            case -1004:
                throw HttpError.serverUnreachableError(message: "Server unreachable")
            default: // - 1009
                throw HttpError.noNetworkError(message: "No network")
            }
        }
        
        if let response = response {
            if response.statusCode == 200
            {
                return data
            }
            
            var errorMessage: String = "";
            
            if let data = data {
                errorMessage = String(data: data, encoding: .utf8) ?? ""
            }
            
            switch response.statusCode {
            case 400:
                throw HttpError.badRequestError(message: errorMessage)
            case 401:
                throw HttpError.notAuthorizeError(message: errorMessage)
            case 403:
                throw HttpError.forbiddenError(message: errorMessage)
            case 404:
                throw HttpError.notFoundError(message: errorMessage)
            case 405:
                throw HttpError.methodNotAllowedError(message: errorMessage)
            case 409:
                throw HttpError.conflictError(message: errorMessage)
            case 500:
                throw HttpError.internalError(message: errorMessage)
            default:
                throw HttpError.noNetworkError(message: errorMessage)
            }
        }
        return nil
    }
}

extension URLSession {
    func performSynchronously(request: URLRequest) -> (Data?, HTTPURLResponse?, URLError?) {
        let semaphore = DispatchSemaphore(value: 0)
        
        var data: Data?
        var response: HTTPURLResponse?
        var error: URLError?
        
        let task = self.dataTask(with: request) {
            data = $0
            response = $1 as? HTTPURLResponse
            error = $2 as? URLError
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        
        return (data, response, error)
    }
}

enum HttpError: Error {
    case internalError(message: String?)
    case badRequestError(message: String?)
    case noNetworkError(message: String?)
    case notFoundError(message: String?)
    case conflictError(message: String?)
    case methodNotAllowedError(message: String?)
    case notAuthorizeError(message: String?)
    case forbiddenError(message: String?)
    case requestTimedOutError(message: String?)
    case serverUnreachableError(message: String?)

    public var statusCode: Int {
        get {
            switch self {
            case .internalError:
                return 500
            case .badRequestError:
                return 400
            case .notFoundError:
                return 404
            case .conflictError:
                return 401
            case .methodNotAllowedError:
                return 405
            case .notAuthorizeError:
                return 401
            case .forbiddenError:
                return 403
            default:
                return 0
            }
        }
    }
    
    public var errorMessage: String? {
        get {
            switch self {
            case .internalError(let message):
                return message
            case .badRequestError(let message):
                return message
            case .notFoundError(let message):
                return message
            case .conflictError(let message):
                return message
            case .methodNotAllowedError(let message):
                return message
            case .notAuthorizeError(let message):
                return message
            case .forbiddenError(let message):
                return message
            case .requestTimedOutError(let message):
                return message
            case .serverUnreachableError(let message):
                return message
            case .noNetworkError(let message):
                return message
            }
        }
    }
}
