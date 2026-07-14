//
//  MarketMapper.swift
//  CoinFlow
//
//  Created by Ece Akcay on 14.07.2026.
//

import Foundation

//Yani API’den gelen modeli uygulama içine uygun hale çeviriyor.
enum MarketMapper {
    
    static func map(_ dto: CryptoCurrencyDTO) -> CryptoCurrency {
        
        return CryptoCurrency(
            id: dto.id,
            symbol: dto.symbol,
            name: dto.name,
            imageURL: dto.image,
            currentPrice: dto.currentPrice,
            marketCap: dto.marketCap,
            marketCapRank: dto.marketCapRank,
            priceChangePercentage24h: dto.priceChangePercentage24h
        )
    }
    
    static func map(_ dtos: [CryptoCurrencyDTO]) -> [CryptoCurrency] {
        return dtos.map { map($0) }
    }
}
