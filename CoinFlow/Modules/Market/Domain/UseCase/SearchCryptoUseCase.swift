//
//  SearchCryptoUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 20.07.2026.
//

import Foundation

final class FetchMarketCoinsUseCase {
    
    private let repository: MarketRepositoryProtocol
    
    init(repository: MarketRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [CryptoCurrency] {
        return try await repository.fetchMarketCoins()
    }
    
}
