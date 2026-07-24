//
//  ToggleFavoriteCoinUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 21.07.2026.
//

import Foundation

final class ToggleFavoriteCoinUseCase {

    private let repository: FavoriteRepositoryProtocol

    init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
    }

    func execute(coinId: String) -> Bool {
        let isFavorite = repository.isFavorite(coinId: coinId)

        if isFavorite {
            repository.removeFavorite(coinId: coinId)
            return false
        } else {
            repository.addFavorite(coinId: coinId)
            return true
        }
    }
}
