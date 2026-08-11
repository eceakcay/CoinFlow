//
//  MarketAPIService.swift
//  CoinFlow
//
//  Created by Ece Akcay on 14.07.2026.
//

import Foundation

final class MarketAPIService {
    
    // MARK: - Properties
    
    private let apiClient: APIClient
    
    // MARK: - Init
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - API Requests
    
    func fetchMarketCoins(page: Int, vsCurrency: String) async throws -> [CryptoCurrencyDTO] {
        return try await apiClient.request(
            CryptoEndpoint.marketCoins(
                page: page,
                vsCurrency: vsCurrency
            )
        )
    }
    
    func fetchSearchCoins(query: String) async throws -> SearchCoinResponseDTO {
        return try await apiClient.request(
            CryptoEndpoint.searchCoins(query: query)
        )
    }
    
    func fetchMarketCoins(ids: [String], vsCurrency: String) async throws -> [CryptoCurrencyDTO] {
        return try await apiClient.request(
            CryptoEndpoint.marketCoinsByIds(
                ids: ids,
                vsCurrency: vsCurrency
            )
        )
    }
    
    func fetchCoinChart(coinId: String,days: Int,vsCurrency: String) async throws -> CoinChartDTO {
        return try await apiClient.request(
            CryptoEndpoint.marketChart(
                coinId: coinId,
                days: days,
                vsCurrency: vsCurrency
            )
        )
    }
}
