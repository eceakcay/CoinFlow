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
    
    func fetchMarketCoins() async throws -> [CryptoCurrencyDTO] {
        return try await apiClient.request(CryptoEndpoint.marketCoins)
    }
    
}
