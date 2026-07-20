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
    
    private let fetchMarketCoinsUseCase : FetchMarketCoinsUseCase
    private let searchCryptoUseCase: SearchCryptoUseCase
    
    private(set) var coins: [CryptoCurrency] = []
    
    var onStateChange: ((State) -> Void)?
    private var searchTask: Task<Void, Never>?

    
    init(fetchMarketCoinsUseCase: FetchMarketCoinsUseCase, searchCryptoUseCase: SearchCryptoUseCase){
        self.fetchMarketCoinsUseCase = fetchMarketCoinsUseCase
        self.searchCryptoUseCase = searchCryptoUseCase
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
    
    func search(query: String) {
        searchTask?.cancel()
        
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else {
            fetchCoins()
            return
        }
        
        searchTask = Task { [weak self] in
            guard let self else { return }
            
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            guard !Task.isCancelled else {
                return
            }
            
            await MainActor.run {
                self.onStateChange?(.loading)
            }
            
            do {
                let searchedCoins = try await self.searchCryptoUseCase.execute(query: trimmedQuery)
                
                await MainActor.run {
                    self.coins = searchedCoins
                    self.onStateChange?(.success)
                }
            } catch {
               await MainActor.run {
                   self.onStateChange?(.failure(error.localizedDescription))
                }
            }
        }
    }
    
}
