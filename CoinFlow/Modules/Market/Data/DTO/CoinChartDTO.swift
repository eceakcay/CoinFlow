//
//  CoinChartDTO.swift
//  CoinFlow
//
//  Created by Ece Akcay on 21.07.2026.
//

import Foundation

struct CoinChartDTO: Decodable {
    let prices : [[Double]]
    let marketCaps : [[Double]]
    let totalVolumes : [[Double]]
    
    enum CodingKeys: String, CodingKey {
        case prices
        case marketCaps = "market_caps"
        case totalVolumes = "total_volumes"
    }
}
