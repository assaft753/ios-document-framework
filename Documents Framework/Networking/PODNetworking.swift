//
//  PODNetworking.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 25/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation
struct PODNetworking {
    
    enum HttpMethod: String {
        case GET
        case POST
        case PUT
        case DELETE
    }
    
    public func request(httpMethod: HttpMethod, entryPoint: String = "", body: /*[AnyHashable : Any]*/Encodable? = nil, queryParam: [String: String]? = nil) throws -> Data? {
        let (baseUrl, token) = try getBaseUrlAndToken()
        let serverMode = getServerMode()
        
        var headers: [String: String] = [
            Consts.AUTHORIZATION_STR: "\(Consts.BEARER_STR) \(token)"
        ]
        
        headers[Consts.SERVER_MODE_STR] = serverMode
        
        var url: String = baseUrl
        
        let y = baseUrl[baseUrl.startIndex..<baseUrl.endIndex]
        
        if url.last == "/" {
            url = String(baseUrl[baseUrl.startIndex...baseUrl.index(before: baseUrl.endIndex)])
        }
        
        if entryPoint.first != "/" {
            url = "\(url)/\(entryPoint)"
        }
        else {
            url = "\(url)\(entryPoint)"
        }
        
        
        return try HttpClient().request(url: url, method: httpMethod.rawValue, queryParam: queryParam, body: body, headers: headers)
    }
    
    private func getBaseUrlAndToken() throws -> (String, String) {
        let baseUrl: String
        let token: String
        
        if let storageBaseUrl: String = LocalStorageService.shared.get(for: Consts.URL_KEY) {
            baseUrl = storageBaseUrl
        }
        else {
            throw PODError.podComponentsFromLocalStorageError("No pod url in local storage")
        }
        
        if let storageToken: String = LocalStorageService.shared.get(for: Consts.POD_TOKEN_KEY) {
            token = storageToken
        }
        else {
            throw PODError.podComponentsFromLocalStorageError("No pod token in local storage")
        }
        
        return (baseUrl, token)
    }
    
    private func getServerMode() -> String {
        return
            LocalStorageService.shared.get(for: Consts.SERVER_MODE_KEY, defaultValue: "prod")
    }
}
