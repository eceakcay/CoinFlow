//
//  RemoveFavoriteCoinUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 31.07.2026.
//

import Foundation

final class RemoveFavoriteCoinUseCase {
    
    private let repository: FavoriteRepositoryProtocol
    
    init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(coinId: String) {
        return repository.removeFavorite(coinId: coinId)
    }
}
