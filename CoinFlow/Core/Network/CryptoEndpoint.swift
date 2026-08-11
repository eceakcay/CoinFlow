//
//  CryptoEndpoint.swift
//  CoinFlow
//
//  Created by Ece Akcay on 10.07.2026.
//

import Foundation

enum CryptoEndpoint {
    case marketCoins(page: Int, vsCurrency: String)
    case searchCoins(query: String)
    case marketCoinsByIds(ids: [String], vsCurrency: String)
    case marketChart(coinId: String, days: Int, vsCurrency: String)
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
                
            case .marketChart(let coinId, _, _):
                return "/coins/\(coinId)/market_chart"
            }
        }
        
    var method: HTTPMethod {
        return .get
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .marketCoins(let page, let vsCurrency):
            return [
                URLQueryItem(name: "vs_currency", value: vsCurrency),
                URLQueryItem(name: "order", value: "market_cap_desc"),
                URLQueryItem(name: "per_page", value: "30"),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "sparkline", value: "false")
            ]
            
        case .searchCoins(let query):
            return [
                URLQueryItem(name: "query", value: query)
            ]
            
        case .marketCoinsByIds(let ids, let vsCurrency):
            return [
                URLQueryItem(name: "vs_currency", value: vsCurrency),
                URLQueryItem(name: "ids", value: ids.joined(separator: ",")),
                URLQueryItem(name: "order", value: "market_cap_desc"),
                URLQueryItem(name: "sparkline", value: "false")
            ]
            
        case .marketChart(_, let days, let vsCurrency):
            return [
                URLQueryItem(name: "vs_currency", value: vsCurrency),
                URLQueryItem(name: "days", value: "\(days)")
            ]
        }
    }
    
    var headers: [String : String]? {
        return [
            "accept": "application/json",
            "x-cg-demo-api-key": APIKeys.coinGeckoDemoAPIKey
        ]
    }
    
    var body: Data? {
        return nil
    }
}
