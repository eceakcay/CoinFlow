//
//  MarketViewModel.swift
//  CoinFlow
//
//  Created by Ece Akcay on 16.07.2026.
//

import Foundation

//MarketViewController -> MarketViewModel -> UseCase -> Repository protocol -> Impl -> Service -> API

final class MarketViewModel {
    
    //MARK: - State
    
    enum State {
        case idle
        case loading
        case empty
        case success
        case partialSuccess(String)
        case failure(String)
    }
    
    // MARK: - Properties
    
    private let fetchMarketCoinsUseCase : FetchMarketCoinsUseCase
    private let searchCryptoUseCase: SearchCryptoUseCase
    private let getFavoriteCoinIdsUseCase: GetFavoriteCoinIdsUseCase
    private let removeFavoriteCoinUseCase: RemoveFavoriteCoinUseCase
    private let userDefaultsManager: UserDefaultsManager
    
    private(set) var coins: [CryptoCurrency] = []
    
    var onStateChange: ((State) -> Void)?
    private var searchTask: Task<Void, Never>?
    private var paginationTask: Task<Void, Never>?
    
    
    // Pagination değişkenleri
    private var currentPage = 1 //hangi sayfadayım
    private let pageSize = 30 //istekte kaç coin çekiyorum
    private var isLoading = false //API isteği var mı
    private var canLoadMore = true //daha fazla veri çekebilir mi
    private var isSearching = false //kullanıcı search modunda mı
    private var hasLoadedOnce = false //coin listesi daha önce yüklendi mi
    
    private var lastFetchedFavoriteIds: Set<String> = []
    private var lastFetchedCurrency: String?
    private var lastFetchDate: Date?
    private let refreshInterval: TimeInterval = 60
    
    //MARK: - Init
    
    init(fetchMarketCoinsUseCase: FetchMarketCoinsUseCase, searchCryptoUseCase: SearchCryptoUseCase, removeFavoriteCoinUseCase: RemoveFavoriteCoinUseCase, userDefaultsManager: UserDefaultsManager, getFavoriteCoinIdsUseCase: GetFavoriteCoinIdsUseCase){
        self.fetchMarketCoinsUseCase = fetchMarketCoinsUseCase
        self.searchCryptoUseCase = searchCryptoUseCase
        self.removeFavoriteCoinUseCase = removeFavoriteCoinUseCase
        self.userDefaultsManager = userDefaultsManager
        self.getFavoriteCoinIdsUseCase = getFavoriteCoinIdsUseCase
    }
    
    //MARK: - Lifecycle
    
    func viewWillAppear() {
        guard hasLoadedOnce else {
            return
        }

        // Devam eden API isteği varsa tekrar istek atma
        guard !isLoading else {
            return
        }

        let currentCurrency = userDefaultsManager.appCurrency.apiValue

        // Para birimi değiştiyse direkt yenile
        if currentCurrency != lastFetchedCurrency {
            fetchCoins()
            return
        }

        // Daha önce başarılı fetch olmadıysa tekrar dene
        guard let lastFetchDate else {
            fetchCoins()
            return
        }

        // Son başarılı fetch'ten 60 saniye geçtiyse yenile
        let elapsedTime = Date().timeIntervalSince(lastFetchDate)

        if elapsedTime >= refreshInterval {
            fetchCoins()
        }
    }
    
    func viewDidLoad() {
        guard !hasLoadedOnce else { return }
        
        hasLoadedOnce = true
        fetchCoins()
    }
    
    
    //ilk sayfayı çeker
    func fetchCoins() {
        // Devam eden search varsa iptal et
        searchTask?.cancel()
        searchTask = nil
        
        // Devam eden pagination isteği varsa iptal et
        paginationTask?.cancel()
        paginationTask = nil
        
        isSearching = false
        isLoading = false
        
        currentPage = 1
        canLoadMore = true
        
        fetchPage(page: currentPage)
    }
    
    func loadNextPageIfNeeded(currentIndex: Int) {
        guard !isSearching else {
            return
        }
        
        guard !isLoading, canLoadMore else {
            return
        }
        
        let thresholdIndex = coins.count - 5 //eşik
        
        guard currentIndex >= thresholdIndex else {
            return
        }
        
        fetchPage(page: currentPage + 1)
    }
    
    //yeni sayfa çeker(pagination)
    private func fetchPage(page: Int) {
        
        // Search yapılırken pagination çalışmasın
        guard !isSearching else {
            return
        }
        
        guard !isLoading, canLoadMore else {
            return
        }
        
        isLoading = true
        
        if page == 1 {
            onStateChange?(.loading)
        }
        
        paginationTask = Task { [weak self] in
            guard let self else { return }
            
            let vsCurrency = self.userDefaultsManager.appCurrency.apiValue
            
            do {
                let newCoins = try await self.fetchMarketCoinsUseCase.execute(
                    page: page,
                    vsCurrency: vsCurrency
                )
                
                // Bu task search başladığı için iptal edilmiş olabilir.
                guard !Task.isCancelled else {
                    return
                }
                
                await MainActor.run {
                    
                    // Network isteği bittikten sonra search başlamış olabilir.
                    // Eski pagination sonucunun search sonucunu ezmesini engelliyoruz.
                    guard !self.isSearching else {
                        return
                    }
                    
                    self.isLoading = false
                    self.lastFetchedCurrency = vsCurrency

                    if page == 1 {
                        self.lastFetchDate = Date()
                    }

                    if newCoins.count < self.pageSize {
                        self.canLoadMore = false
                    }
                    
                    if page == 1 {
                        self.coins = newCoins
                    } else {
                        self.coins.append(contentsOf: newCoins)
                    }
                    
                    self.currentPage = page
                    
                    if self.coins.isEmpty {
                        self.onStateChange?(.empty)
                    } else {
                        self.onStateChange?(.success)
                    }
                }
                
            } catch {
                
                // Biz kendimiz cancel ettiysek bunu hata olarak gösterme
                guard !Task.isCancelled else {
                    return
                }
                
                guard !self.isCancellationError(error) else {
                    return
                }
                
                await MainActor.run {
                    self.isLoading = false
                    
                    if self.coins.isEmpty {
                        self.onStateChange?(
                            .failure(error.localizedDescription)
                        )
                    } else {
                        self.onStateChange?(
                            .partialSuccess(error.localizedDescription)
                        )
                    }
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
    
    func search(query: String) {
        
        // Önceki search isteğini iptal et
        searchTask?.cancel()
        
        let trimmedQuery = query.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        // Search boşsa normal market listesine dön
        guard !trimmedQuery.isEmpty else {
            fetchCoins()
            return
        }
        
        // Artık search modundayız
        isSearching = true
        
        // Devam eden pagination isteğini durdur
        paginationTask?.cancel()
        paginationTask = nil
        
        // Pagination loading durumunu temizle
        isLoading = false
        
        // Search sırasında pagination yapılmayacak
        canLoadMore = false
        
        searchTask = Task { [weak self] in
            guard let self else { return }
            
            // Debounce - kullanıcı yazmayı bitirsin
            try? await Task.sleep(
                nanoseconds: 500_000_000
            )
            
            guard !Task.isCancelled else {
                return
            }
            
            await MainActor.run {
                self.onStateChange?(.loading)
            }
            
            do {
                let vsCurrency =
                    self.userDefaultsManager.appCurrency.apiValue
                
                let searchedCoins =
                    try await self.searchCryptoUseCase.execute(
                        query: trimmedQuery,
                        vsCurrency: vsCurrency
                    )
                
                // Kullanıcı bu sırada başka bir kelime yazmış olabilir
                guard !Task.isCancelled else {
                    return
                }
                
                await MainActor.run {
                    
                    // Search artık kapatıldıysa eski sonucu gösterme
                    guard self.isSearching else {
                        return
                    }
                    
                    self.lastFetchedCurrency = vsCurrency
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
                
                guard !self.isCancellationError(error) else {
                    return
                }
                
                await MainActor.run {
                    self.onStateChange?(
                        .failure(error.localizedDescription)
                    )
                }
            }
        }
    }
    
}
