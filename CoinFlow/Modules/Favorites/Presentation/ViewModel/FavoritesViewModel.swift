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
    private(set) var coins: [CryptoCurrency] = []
    
    var onStateChange: ((State) -> Void)?
    
    //rate limit için throttling
    private var isLoading = false
    private var lastFetchDate: Date?
    private let minimumRefreshInterval: TimeInterval = 20
    
    init(fetchFavoriteCoinsUseCase: FetchFavoriteCoinsUseCase) {
        self.fetchFavoriteCoinsUseCase = fetchFavoriteCoinsUseCase
    }
    
    func viewWillAppear () {
        if let lastFetchDate,
           Date().timeIntervalSince(lastFetchDate) < minimumRefreshInterval {
            return
        }
        fetchFavorites()
    }
    
    func fetchFavorites() {
        
        guard !isLoading else { return } 
        
        isLoading = true
        lastFetchDate = Date()
        
        onStateChange?(.loading)//ekran açıldığında loading yapıyoruz
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let favoriteCoins = try await self.fetchFavoriteCoinsUseCase.execute()
                
                await MainActor.run {//UI güncellemesi yapılacağı için
                    self.isLoading = false
                    self.coins = favoriteCoins
                    
                    if favoriteCoins.isEmpty {
                        self.onStateChange?(.empty)
                    }
                    else {
                        self.onStateChange?(.success)
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.onStateChange?(.failure(error.localizedDescription))
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
}
