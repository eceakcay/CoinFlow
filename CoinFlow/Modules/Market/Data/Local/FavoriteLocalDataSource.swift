//
//  FavoriteLocalDataSource.swift
//  CoinFlow
//
//  Created by Ece Akcay on 21.07.2026.
//

import Foundation

final class FavoriteLocalDataSource {
    
    private let userDefaults: UserDefaults
    private let favoritesKey = "favorite_coin_ids"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func getFavoriteIds() ->Set<String> {
        let ids = userDefaults.stringArray(forKey: favoritesKey) ?? []
        return Set(ids)
    }
    
    func saveFavoriteIds(_ ids: Set<String>) {
        userDefaults.set(Array(ids), forKey: favoritesKey)
    }
    
    func isFavorite(coinId: String) -> Bool {
        return getFavoriteIds().contains(coinId)
    }
    
    func addFavorite(coinId: String) {
        var ids = getFavoriteIds()
        ids.insert(coinId)
        saveFavoriteIds(ids)
    }
    
    func removeFavorite(coinId: String) {
        var ids = getFavoriteIds()
        ids.remove(coinId)
        saveFavoriteIds(ids)
    }
    
    
}
