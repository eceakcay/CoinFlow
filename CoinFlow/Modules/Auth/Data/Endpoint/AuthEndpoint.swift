//
//  AuthEndpoint.swift
//  CoinFlow
//
//  Created by Ece Akcay on 12.08.2026.
//

import Foundation

enum AuthEndpoint {
    case login(request: LoginRequestDTO)
}

extension AuthEndpoint: Endpoint {

    var baseURL: String {
        "https://dummyjson.com"
    }

    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        }
    }

    var queryItems: [URLQueryItem]? {
        nil
    }

    var headers: [String : String]? {
        [
            "Content-Type": "application/json"
        ]
    }

    var body: Data? {
        switch self {
        case .login(let request):
            return try? JSONEncoder().encode(request)
        }
    }
}
