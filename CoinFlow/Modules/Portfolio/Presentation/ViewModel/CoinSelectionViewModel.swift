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
    
    private var initialCoins: [CryptoCurrency] = []

    
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
            if coins.isEmpty {
                onStateChange?(.empty)
            } else {
                onStateChange?(.success)
            }
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
                    self.initialCoins = Array(coins.prefix(20))
                    self.coins = self.initialCoins
                    
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
            coins = initialCoins
            
            if coins.isEmpty {
                onStateChange?(.empty)
            } else {
                onStateChange?(.success)
            }
            
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
            }  catch {
                guard !Task.isCancelled else {
                    return
                }
                
                guard !self.isCancellationError(error) else {
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
    
    private func isCancellationError(_ error: Error) -> Bool {
        if error is CancellationError {
            return true
        }
        
        if let urlError = error as? URLError,
           urlError.code == .cancelled {
            return true
        }
        
        if case NetworkError.unknown(let underlyingError) = error,
           let urlError = underlyingError as? URLError,
           urlError.code == .cancelled {
            return true
        }
        
        return error.localizedDescription.lowercased().contains("cancelled")
    }
}
