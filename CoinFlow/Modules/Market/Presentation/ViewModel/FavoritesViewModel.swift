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
    
    init(fetchFavoriteCoinsUseCase: FetchFavoriteCoinsUseCase) {
        self.fetchFavoriteCoinsUseCase = fetchFavoriteCoinsUseCase
    }
    
    func viewWillAppear () {
        fetchFavorites()
    }
    
    func fetchFavorites() {
        onStateChange?(.loading)//ekran açıldığında loading yapıyoruz
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let favoriteCoins = try await self.fetchFavoriteCoinsUseCase.execute()
                
                await MainActor.run {//UI güncellemesi yapılacağı için
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
