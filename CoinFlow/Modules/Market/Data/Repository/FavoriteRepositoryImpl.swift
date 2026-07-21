//
//  FavoriteRepositoryImpl.swift
//  CoinFlow
//
//  Created by Ece Akcay on 21.07.2026.
//

import Foundation

final class FavoriteRepositoryImpl: FavoriteRepositoryProtocol {
    
    private let localDataSource : FavoriteLocalDataSource
    
    init(localDataSource: FavoriteLocalDataSource) {
        self.localDataSource = localDataSource
    }
    
    func isFavorite(coinId: String) -> Bool {
        return localDataSource.isFavorite(coinId: coinId)
    }
    
    func removeFavorite(coinId: String) {
        localDataSource.removeFavorite(coinId: coinId)
    }
    
    func addFavorite(coinId: String) {
        localDataSource.addFavorite(coinId: coinId)
    }
    
}
