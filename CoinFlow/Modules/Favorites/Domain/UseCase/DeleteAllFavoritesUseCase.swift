//
//  DeleteAllFavoritesUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 19.08.2026.
//

import Foundation

final class DeleteAllFavoritesUseCase {

    // MARK: - Dependencies

    private let repository: FavoriteRepositoryProtocol

    // MARK: - Init

    init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execute

    func execute() {
        repository.deleteAllFavorites()
    }
}
