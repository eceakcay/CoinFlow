//
//  MarketAPIService.swift
//  CoinFlow
//
//  Created by Ece Akcay on 14.07.2026.
//

import Foundation

final class MarketAPIService {
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func fetchMarketCoins(page: Int) async throws -> [CryptoCurrencyDTO] {
        return try await apiClient.request(
            CryptoEndpoint.marketCoins(page: page)
        )
    }
    
    func fetchSearchCoins(query: String) async throws -> SearchCoinResponseDTO {
        return try await apiClient.request(CryptoEndpoint.searchCoins(query: query))
    }
    
    func fetchMarketCoins(ids: [String]) async throws -> [CryptoCurrencyDTO] {
        return try await apiClient.request(
            CryptoEndpoint.marketCoinsByIds(ids: ids)
        )
    }
}
