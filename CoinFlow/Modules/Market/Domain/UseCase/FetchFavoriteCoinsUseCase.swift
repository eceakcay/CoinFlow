//
//  FetchFavoriteCoinsUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 22.07.2026.
//

import Foundation

final class FetchFavoriteCoinsUseCase {
    
    private let favoriteRepository: FavoriteRepositoryProtocol
    private let marketRepository: MarketRepositoryProtocol
    
    init(favoriteRepository: FavoriteRepositoryProtocol, marketRepository: MarketRepositoryProtocol) {
        self.favoriteRepository = favoriteRepository
        self.marketRepository = marketRepository
    }
    
    func execute() async throws -> [CryptoCurrency] {
        let favoriteIds = favoriteRepository.getFavoriteIds()
        
        guard !favoriteIds.isEmpty else {
            return []
        }
        
        return try await marketRepository.fetchMarketCoins(ids: favoriteIds)

    }
    
}
