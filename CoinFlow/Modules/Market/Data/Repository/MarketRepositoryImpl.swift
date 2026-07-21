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
    
    func fetchMarketCoins(page: Int) async throws -> [CryptoCurrency] {
        let dtos = try await service.fetchMarketCoins(page: page)
        return MarketMapper.map(dtos)
    }
    
    func searchCoins(query: String) async throws -> [CryptoCurrency] {
        
        let searchResponse = try await service.fetchSearchCoins(query: query)
        let ids = searchResponse.coins
            .prefix(10)
            .map { $0.id }

        guard !ids.isEmpty else {
            return []
        }
        
        let marketDTOs = try await service.fetchMarketCoins(ids: Array(ids))
        return MarketMapper.map(marketDTOs)
    }
    
    
    
}
