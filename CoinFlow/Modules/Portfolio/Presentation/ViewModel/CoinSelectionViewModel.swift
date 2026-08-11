//
//  CoinSelectionViewModel.swift
//  CoinFlow
//
//  Created by Ece Akcay on 31.07.2026.
//

import Foundation

final class CoinSelectionViewModel {
    
    // MARK: - State
    
    enum State {
        case idle
        case loading
        case success
        case empty
        case failure(String)
    }
    
    // MARK: - Properties
    
    private let fetchMarketCoinsUseCase: FetchMarketCoinsUseCase
    private let searchCryptoUseCase: SearchCryptoUseCase
    private let userDefaultsManager: UserDefaultsManager
    
    private(set) var coins: [CryptoCurrency] = []
    
    var onStateChange: ((State) -> Void)?
    
    private var searchTask: Task<Void, Never>?
    private var hasLoadedInitialCoins = false
    
    // MARK: - Init
    
    init(
        searchCryptoUseCase: SearchCryptoUseCase,
        fetchMarketCoinsUseCase: FetchMarketCoinsUseCase,
        userDefaultsManager: UserDefaultsManager
    ) {
        self.searchCryptoUseCase = searchCryptoUseCase
        self.fetchMarketCoinsUseCase = fetchMarketCoinsUseCase
        self.userDefaultsManager = userDefaultsManager
    }
    
    // MARK: - Lifecycle
    
    func viewDidLoad() {
        fetchInitialCoins()
    }
    
    // MARK: - Actions
    
    func fetchInitialCoins() {
        guard !hasLoadedInitialCoins else {
            onStateChange?(.success)
            return
        }
        
        hasLoadedInitialCoins = true
        onStateChange?(.loading)
        
        Task { [weak self] in
            guard let self else { return }
            
            let vsCurrency = self.userDefaultsManager.appCurrency.apiValue
            
            do {
                let coins = try await self.fetchMarketCoinsUseCase.execute(
                    page: 1,
                    vsCurrency: vsCurrency
                )
                
                await MainActor.run {
                    self.coins = Array(coins.prefix(20))
                    
                    if self.coins.isEmpty {
                        self.onStateChange?(.empty)
                    } else {
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
    
    func search(query: String) {
        searchTask?.cancel()
        
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else {
            coins = []
            onStateChange?(.empty)
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
            
            let vsCurrency = self.userDefaultsManager.appCurrency.apiValue
            
            do {
                let searchedCoins = try await self.searchCryptoUseCase.execute(
                    query: trimmedQuery,
                    vsCurrency: vsCurrency
                )
                
                guard !Task.isCancelled else {
                    return
                }
                
                await MainActor.run {
                    self.coins = searchedCoins
                    
                    if searchedCoins.isEmpty {
                        self.onStateChange?(.empty)
                    } else {
                        self.onStateChange?(.success)
                    }
                }
            } catch {
                guard !Task.isCancelled else {
                    return
                }
                
                await MainActor.run {
                    self.onStateChange?(.failure(error.localizedDescription))
                }
            }
        }
    }
    
    // MARK: - Table Helpers
    
    func numberOfRows() -> Int {
        coins.count
    }
    
    func coin(at index: Int) -> CryptoCurrency? {
        guard coins.indices.contains(index) else {
            return nil
        }
        
        return coins[index]
    }
}
