//
//  GetFavoriteCoinIdsUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 27.07.2026.
//

import Foundation

final class GetFavoriteCoinIdsUseCase {

    private let repository: FavoriteRepositoryProtocol

    init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> [String] {
        return repository.getFavoriteIds().sorted()
    }
}
