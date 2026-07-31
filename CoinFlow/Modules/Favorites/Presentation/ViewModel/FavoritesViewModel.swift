//
//  FavoritesViewModel.swift
//  CoinFlow
//
//  Created by Ece Akcay on 22.07.2026.
//

import Foundation

final class FavoritesViewModel {
    
    enum State {
        case idle
        case empty
        case loading
        case success
        case failure(String)
    }
    
    private let fetchFavoriteCoinsUseCase : FetchFavoriteCoinsUseCase
    private let getFavoriteCoinIdsUseCase: GetFavoriteCoinIdsUseCase
    private let removeFavoriteCoinUseCase: RemoveFavoriteCoinUseCase
    
    private(set) var coins: [CryptoCurrency] = []
    
    var onStateChange: ((State) -> Void)?
    
    //rate limit için throttling
    private var isLoading = false
    private var lastFetchedFavoriteIds: Set<String> = []
    private var lastFetchDate: Date?
    private let minimumRefreshInterval: TimeInterval = 20
    
    init(fetchFavoriteCoinsUseCase: FetchFavoriteCoinsUseCase, getFavoriteCoinIdsUseCase: GetFavoriteCoinIdsUseCase, removeFavoriteCoinUseCase: RemoveFavoriteCoinUseCase) {
        self.fetchFavoriteCoinsUseCase = fetchFavoriteCoinsUseCase
        self.getFavoriteCoinIdsUseCase = getFavoriteCoinIdsUseCase
        self.removeFavoriteCoinUseCase = removeFavoriteCoinUseCase
    }
    
    func viewWillAppear() {
        let currentFavoriteIds = Set(getFavoriteCoinIdsUseCase.execute())

        if currentFavoriteIds.isEmpty {
            coins = []
            lastFetchedFavoriteIds = []
            onStateChange?(.empty)
            return
        }

        let idsChanged = currentFavoriteIds != lastFetchedFavoriteIds

        let shouldRefreshByTime: Bool

        if let lastFetchDate {
            shouldRefreshByTime = Date().timeIntervalSince(lastFetchDate) > minimumRefreshInterval
        } else {
            shouldRefreshByTime = true
        }

        guard idsChanged || coins.isEmpty || shouldRefreshByTime else {
            onStateChange?(.success)
            return
        }

        fetchFavorites(currentFavoriteIds: currentFavoriteIds)
    }
    
    private func fetchFavorites(currentFavoriteIds: Set<String>) {
        guard !isLoading else {
            return
        }

        isLoading = true
        onStateChange?(.loading)

        Task { [weak self] in
            guard let self else { return }

            do {
                let favoriteCoins = try await self.fetchFavoriteCoinsUseCase.execute()

                await MainActor.run {
                    self.isLoading = false
                    self.lastFetchDate = Date()
                    self.lastFetchedFavoriteIds = currentFavoriteIds
                    self.coins = favoriteCoins

                    if favoriteCoins.isEmpty {
                        self.onStateChange?(.empty)
                    } else {
                        self.onStateChange?(.success)
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false

                    if self.coins.isEmpty {
                        self.onStateChange?(.failure(error.localizedDescription))
                    } else {
                        print("Favorites refresh error:", error.localizedDescription)
                        self.onStateChange?(.success)
                    }
                }
            }
        }
    }
    
    func numberOfRows() -> Int {
        return coins.count
    }
    
    func coin(at index: Int) -> CryptoCurrency? {
        guard coins.indices.contains(index) else { return nil }
        
        return coins[index]
    }
    
    func removeFavorite(at index: Int) {
        guard coins.indices.contains(index) else { return }
        
        let coin = coins[index]
        
        removeFavoriteCoinUseCase.execute(coinId: coin.id)
        coins.remove(at: index)
        lastFetchedFavoriteIds.remove(coin.id)
        
        if coins.isEmpty {
            onStateChange?(.empty)
        } else {
            onStateChange?(.success)
        }
        
        
    }
}
