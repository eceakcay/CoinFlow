//
//  FavoriteRepositoryImpl.swift
//  CoinFlow
//
//  Created by Ece Akcay on 21.07.2026.
//

import Foundation

//FavoriteRepositoryImpl kuralları gerçekten çalıştırıyor
final class FavoriteRepositoryImpl: FavoriteRepositoryProtocol {
    
    private let localDataSource : FavoriteLocalDataSource
    private let cloudSyncService: FirebaseCloudSyncService
    
    init(localDataSource: FavoriteLocalDataSource, cloudSyncService: FirebaseCloudSyncService) {
        self.localDataSource = localDataSource
        self.cloudSyncService = cloudSyncService
    }
    
    func getFavoriteIds() -> [String] {
        return localDataSource.getFavoriteIds()
    }
    
    func isFavorite(coinId: String) -> Bool {
        return localDataSource.isFavorite(coinId: coinId)
    }
    
    func removeFavorite(coinId: String) {
        localDataSource.removeFavorite(coinId: coinId)
        cloudSyncService.enqueueRemoveFavorite(id: coinId)
    }
    
    func addFavorite(coinId: String) {
        localDataSource.addFavorite(coinId: coinId)
        cloudSyncService.enqueueAddFavorite(id: coinId)
    }
    
    func deleteAllFavorites() {
        let ids = localDataSource.getFavoriteIds()
        localDataSource.deleteAllFavorites()
        ids.forEach { cloudSyncService.enqueueRemoveFavorite(id: $0) }
    }
}
