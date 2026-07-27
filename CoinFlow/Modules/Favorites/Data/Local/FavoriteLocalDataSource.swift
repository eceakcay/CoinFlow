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

    func getFavoriteIds() -> [String] {
        let ids = userDefaults.stringArray(forKey: favoritesKey) ?? []
        return ids.sorted()
    }

    private func getFavoriteIdSet() -> Set<String> {
        return Set(getFavoriteIds())
    }

    private func saveFavoriteIds(_ ids: Set<String>) {
        userDefaults.set(Array(ids), forKey: favoritesKey)
    }

    func isFavorite(coinId: String) -> Bool {
        return getFavoriteIdSet().contains(coinId)
    }

    func addFavorite(coinId: String) {
        var ids = getFavoriteIdSet()
        ids.insert(coinId)
        saveFavoriteIds(ids)
        
        print("Saved favorite ids:", getFavoriteIds())
    }

    func removeFavorite(coinId: String) {
        var ids = getFavoriteIdSet()
        ids.remove(coinId)
        saveFavoriteIds(ids)
    }
}
