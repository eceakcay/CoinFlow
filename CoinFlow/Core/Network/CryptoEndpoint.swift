//
//  CryptoEndpoint.swift
//  CoinFlow
//
//  Created by Ece Akcay on 10.07.2026.
//

import Foundation

enum CryptoEndpoint {
    case marketCoins
    case searchCoins(query: String)
    case marketCoinsByIds(ids: [String])//idlere göre getir
}

extension CryptoEndpoint: Endpoint {
    
    var baseURL: String {
        return "https://api.coingecko.com/api/v3"
    }
    
    var path: String {
        switch self {
        case .marketCoins:
            return "/coins/markets"
        case .searchCoins:
            return "/search"
        case .marketCoinsByIds:
            return "/coins/markets"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .marketCoins:
            return .get
        case .searchCoins:
            return .get
        case .marketCoinsByIds:
            return .get
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
            case .marketCoins:
            return [
                URLQueryItem(name: "vs_currency", value: "usd"),
                URLQueryItem(name: "order", value: "market_cap_desc"),
                URLQueryItem(name: "per_page", value: "30"),
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "sparkline", value: "false")
            ]
        case .searchCoins(let query):
            return [
                URLQueryItem(name: "query", value: query)
            ]
        case .marketCoinsByIds(let ids):
            return [
                URLQueryItem(name: "vs_currency", value: "usd"),
                URLQueryItem(name: "ids", value: ids.joined(separator: ",")),
                URLQueryItem(name: "order", value: "market_cap_desc"),
                URLQueryItem(name: "sparkline", value: "false")
            ]
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var body: Data? {
        return nil
    }
}
