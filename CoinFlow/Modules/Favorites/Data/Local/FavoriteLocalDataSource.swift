//
//  FavoriteLocalDataSource.swift
//  CoinFlow
//
//  Created by Ece Akcay on 21.07.2026.
//

import Foundation

final class FavoriteLocalDataSource {

    // MARK: - Properties

    private let userDefaults: UserDefaults
    private let userDefaultsManager: UserDefaultsManager

    private let baseFavoritesKey = "favorite_coin_ids"

    // MARK: - Init

    init(
        userDefaults: UserDefaults = .standard,
        userDefaultsManager: UserDefaultsManager = .shared
    ) {
        self.userDefaults = userDefaults
        self.userDefaultsManager = userDefaultsManager
    }

    // MARK: - Favorite Key

    // Her kullanıcı için farklı UserDefaults key oluşturur.
    private func favoritesKey() -> String? {

        guard let currentUserId = userDefaultsManager.currentUserId,
              !currentUserId.isEmpty else {

            print(" Favorite işlemi yapılamadı - currentUserId nil")
            return nil
        }

        return "\(baseFavoritesKey)_\(currentUserId)"
    }

    // MARK: - Get

    func getFavoriteIds() -> [String] {

        guard let key = favoritesKey() else {
            return []
        }

        let ids = userDefaults.stringArray(forKey: key) ?? []

        print(" Favorite fetch user:", userDefaultsManager.currentUserId ?? "nil")
        print(" Favorite key:", key)
        print(" Favorite ids:", ids)

        return ids.sorted()
    }

    private func getFavoriteIdSet() -> Set<String> {
        return Set(getFavoriteIds())
    }

    // MARK: - Save

    private func saveFavoriteIds(_ ids: Set<String>) {

        guard let key = favoritesKey() else {
            return
        }

        userDefaults.set(
            Array(ids),
            forKey: key
        )
    }

    // MARK: - Check

    func isFavorite(coinId: String) -> Bool {
        return getFavoriteIdSet().contains(coinId)
    }

    // MARK: - Add

    func addFavorite(coinId: String) {

        var ids = getFavoriteIdSet()

        ids.insert(coinId)

        saveFavoriteIds(ids)
    }

    // MARK: - Remove

    func removeFavorite(coinId: String) {

        var ids = getFavoriteIdSet()

        ids.remove(coinId)

        saveFavoriteIds(ids)
    }
    
    func deleteAllFavorites() {

        guard let userId = userDefaultsManager.currentUserId else {
            return
        }

        let key = "favorite_coin_ids_\(userId)"
        UserDefaults.standard.removeObject(forKey: key)
    }
}
