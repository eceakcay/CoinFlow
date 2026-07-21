//
//  CryptoCurrencyDTO.swift
//  CoinFlow
//
//  Created by Ece Akcay on 13.07.2026.
//

import Foundation

//API'den gelen json modelidir
struct CryptoCurrencyDTO: Decodable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double
    let marketCap: Double?
    let marketCapRank: Int?
    let priceChangePercentage24h: Double?
    let totalVolume: Double?

    
    //CodingKeys, JSON'daki alan isimleri ile Swift'teki property isimleri farklı olduğunda bunları eşleştirmek için kullanılır.
    enum CodingKeys : String, CodingKey {
        case id
        case symbol
        case name
        case image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case totalVolume = "total_volume"
    }
}
