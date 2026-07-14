//
//  MarketRepositoryImpl.swift
//  CoinFlow
//
//  Created by Ece Akcay on 14.07.2026.
//

import Foundation

final class MarketRepositoryImpl: MarketRepositoryProtocol {
    
    private let service : MarketAPIService
    
    init(service: MarketAPIService) {
        self.service = service
    }
    
    func fetchMarketCoins() async throws -> [CryptoCurrency] {
        let dtos = try await service.fetchMarketCoins()
        return MarketMapper.map(dtos)
    }
    
    
    
}
