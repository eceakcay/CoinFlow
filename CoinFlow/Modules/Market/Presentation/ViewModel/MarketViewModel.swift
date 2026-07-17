//
//  MarketViewModel.swift
//  CoinFlow
//
//  Created by Ece Akcay on 16.07.2026.
//

import Foundation

//MarketViewController -> MarketViewModel -> UseCase -> Repository -> API

final class MarketViewModel {
    
    enum State {
        case idle
        case loading
        case success
        case failure(String)
    }
    //best practices
    private let fetchMarketCoinsUseCase : FetchMarketCoinsUseCase
    
    private(set) var coins: [CryptoCurrency] = []
    
    var onStateChange: ((State) -> Void)?
    
    init(fetchMarketCoinsUseCase: FetchMarketCoinsUseCase){
        self.fetchMarketCoinsUseCase = fetchMarketCoinsUseCase
    }
    
    func viewDidLoad() {
        fetchCoins()
    }
    
    func fetchCoins() {
        onStateChange?(.loading)
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
               let coins = try await fetchMarketCoinsUseCase.execute()
                
                await MainActor.run {
                    self.coins = coins
                    self.onStateChange?(.success)
                }
            } catch {
                await MainActor.run {
                    self.onStateChange?(.failure(error.localizedDescription))
                }
            }
            
        }
    }
    
    func numberofRows() -> Int {
        coins.count
    }
    
    func coin(at index: Int) -> CryptoCurrency? {
        guard coins.indices.contains(index) else {
            return nil
        }
        return coins[index]
    }
    
}
