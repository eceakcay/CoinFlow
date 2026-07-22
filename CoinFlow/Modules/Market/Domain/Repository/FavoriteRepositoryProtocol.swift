//
//  FavoriteRepositoryProtocol.swift
//  CoinFlow
//
//  Created by Ece Akcay on 21.07.2026.
//

import Foundation

protocol FavoriteRepositoryProtocol { //SÖZLEŞME
    func getFavoriteIds() -> [String]
    func isFavorite(coinId: String) -> Bool
    func removeFavorite(coinId: String)
    func addFavorite(coinId: String) 
}
