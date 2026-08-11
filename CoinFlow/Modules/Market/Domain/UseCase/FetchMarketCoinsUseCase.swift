//
//  FetchMarketCoinsUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 14.07.2026.
//

import Foundation

final class FetchMarketCoinsUseCase {
    
    private let repository: MarketRepositoryProtocol
    
    init(repository: MarketRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(page: Int, vsCurrency: String) async throws -> [CryptoCurrency] {
        return try await repository.fetchMarketCoins(page: page, vsCurrency: vsCurrency )
    }
    
}
