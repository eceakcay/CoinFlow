//
//  IsFavoriteCoinUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 21.07.2026.
//

import Foundation

final class IsFavoriteCoinUseCase {

    private let repository: FavoriteRepositoryProtocol

    init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
    }

    func execute(coinId: String) -> Bool {
        return repository.isFavorite(coinId: coinId)
    }
}
