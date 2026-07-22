//
//  MarketViewModel.swift
//  CoinFlow
//
//  Created by Ece Akcay on 16.07.2026.
//

import Foundation

//MarketViewController -> MarketViewModel -> UseCase -> Repository protocol -> Impl -> Service -> API

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
    
    // Pagination değişkenleri
    private var currentPage = 1
    private let pageSize = 30
    private var isLoading = false
    private var canLoadMore = true
    private var isSearching = false
    private var hashLoadedOnce = false
    

    
    init(fetchMarketCoinsUseCase: FetchMarketCoinsUseCase, searchCryptoUseCase: SearchCryptoUseCase){
        self.fetchMarketCoinsUseCase = fetchMarketCoinsUseCase
        self.searchCryptoUseCase = searchCryptoUseCase
    }
    
    func viewDidLoad() {
        guard !hashLoadedOnce else { return }
        hashLoadedOnce = true
        
        fetchCoins()
    }
    
    //ilk sayfayı çeker
    func fetchCoins() {
        searchTask?.cancel()
        isSearching = false
        
        currentPage = 1
        canLoadMore = true
        coins = []
        
        fetchPage(page: currentPage)
    }
    
    //yeni sayfa çeker
    private func fetchPage(page: Int) {
        guard !isLoading, canLoadMore else { return }
        
        isLoading = true
        
        if page == 1 {
            onStateChange?(.loading)
        }
        
        Task { [weak self] in
            guard let self else { return }
            
            do{
                let newCoins = try await self.fetchMarketCoinsUseCase.execute(page: page)
                
                await MainActor.run {
                    self.isLoading = false
                    
                    if newCoins.count < self.pageSize {
                        self.canLoadMore = false
                    }
                    
                    if page == 1 {
                        self.coins = newCoins
                    } else {
                        self.coins.append(contentsOf: newCoins)
                    }
                    
                    self.currentPage = page
                    self.onStateChange?(.success)
                }
            }
            catch {
                await MainActor.run {
                    self.isLoading = false
                    self.onStateChange?(.failure(error.localizedDescription))
                }
            }
        }
    }
    
    func loadNextPageIfNeeded(currentIndex: Int) {
        guard !isSearching else {
            return
        }
        
        guard !isLoading, canLoadMore else {
            return
        }
        
        let thresholdIndex = coins.count - 5
        
        guard currentIndex >= thresholdIndex else {
            return
        }
        
        fetchPage(page: currentPage + 1)
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
