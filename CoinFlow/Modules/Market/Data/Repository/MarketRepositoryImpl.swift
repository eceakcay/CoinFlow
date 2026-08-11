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
    
    func fetchMarketCoins(page: Int, vsCurrency: String) async throws -> [CryptoCurrency] {
        let dtos = try await service.fetchMarketCoins(page: page, vsCurrency: vsCurrency)
        return MarketMapper.map(dtos)
    }
    
    func searchCoins(query: String, vsCurrency: String) async throws -> [CryptoCurrency] {
        
        let searchResponse = try await service.fetchSearchCoins(query: query)
        let ids = searchResponse.coins
            .prefix(10)
            .map { $0.id }

        guard !ids.isEmpty else {
            return []
        }
        
        let marketDTOs = try await service.fetchMarketCoins(ids: Array(ids), vsCurrency: vsCurrency)
        return MarketMapper.map(marketDTOs)
    }
    
    func fetchMarketCoins(ids: [String], vsCurrency: String) async throws -> [CryptoCurrency] {
        let dtos = try await service.fetchMarketCoins(ids: ids, vsCurrency: vsCurrency)
        return MarketMapper.map(dtos)
    }
    
    func fetchCoinChart(coinId: String,days: Int, vsCurrency: String) async throws -> [CoinChartPoint] {
        let dto = try await service.fetchCoinChart(coinId: coinId,days: days, vsCurrency: vsCurrency)
        return CoinChartMapper.map(dto)
    }
}
