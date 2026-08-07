//
//  DependencyContainer.swift
//  CoinFlow
//
//  Created by Ece Akcay on 8.07.2026.
//

import Foundation

//Uygulamadaki bağımlılıkları oluşturan ve birbirine bağlayan merkez.
final class DependencyContainer {
    
    private lazy var apiClient: APIClient = {
        return APIClient()
    }()
    
    private lazy var marketAPIService: MarketAPIService = {
        return MarketAPIService(apiClient: apiClient)
    }()
    
    private lazy var marketRepository: MarketRepositoryProtocol = {
        return MarketRepositoryImpl(service: marketAPIService)
    }()
    
    private lazy var favoriteRepository: FavoriteRepositoryProtocol = {
        return FavoriteRepositoryImpl(localDataSource: favoriteLocalDataSource)
    }()
    
    private lazy var favoriteLocalDataSource: FavoriteLocalDataSource = {
        return FavoriteLocalDataSource()
    }()
    
    // portfolioLocalDataSource oluştur
    private lazy var portfolioLocalDataSource: PortfolioLocalDataSource = {
        return PortfolioLocalDataSource()
    }()
    
    private lazy var portfolioSummaryCalculator : PortfolioSummaryCalculator = {
        return PortfolioSummaryCalculator()
    }()
    
    private lazy var portfolioRepository: PortfolioRepositoryProtocol = {
        return PortfolioRepositoryImpl(localDataSource: portfolioLocalDataSource) //Impl içine ver
    }()
    
    private lazy var dashboardPresentationMapper: DashboardPresentationMapper = {
        DashboardPresentationMapper()
    }()
    
    func makeMarketViewModel() -> MarketViewModel {
        let fetchUseCase = FetchMarketCoinsUseCase(repository: marketRepository)
        let searchUseCase = SearchCryptoUseCase(repository: marketRepository)
        return MarketViewModel(fetchMarketCoinsUseCase: fetchUseCase,searchCryptoUseCase: searchUseCase
        )
    }
    
    func makeFavoritesViewModel() -> FavoritesViewModel {
        let fetchUseCase = FetchFavoriteCoinsUseCase(favoriteRepository: favoriteRepository, marketRepository: marketRepository)
        let getFavoriteCoinIdsUseCase = GetFavoriteCoinIdsUseCase(repository: favoriteRepository)
        let removeFavoriteCoinUseCase = RemoveFavoriteCoinUseCase(repository: favoriteRepository)
        return FavoritesViewModel(fetchFavoriteCoinsUseCase: fetchUseCase, getFavoriteCoinIdsUseCase: getFavoriteCoinIdsUseCase, removeFavoriteCoinUseCase: removeFavoriteCoinUseCase)
    }
    
    func makeCryptoDetailViewModel(coin: CryptoCurrency) -> CryptoDetailViewModel {
        let isFavoriteCoinUseCase = IsFavoriteCoinUseCase(
            repository: favoriteRepository
        )

        let toggleFavoriteCoinUseCase = ToggleFavoriteCoinUseCase(
            repository: favoriteRepository
        )
        
        let fetchCoinChartUseCase = FetchCoinChartUseCase(
            repository: marketRepository
        )

        return CryptoDetailViewModel(
            coin: coin,
            isFavoriteCoinUseCase: isFavoriteCoinUseCase,
            toggleFavoriteCoinUseCase: toggleFavoriteCoinUseCase,
            fetchCoinChartUseCase: fetchCoinChartUseCase
        )
    }
    
    func makePortfolioViewModel() -> PortfolioViewModel {
        let fetchPortfolioTransactionsUseCase = FetchPortfolioTransactionsUseCase(repository: portfolioRepository)
        let deletePortfolioTransactionUseCase = DeletePortfolioTransactionUseCase(repository: portfolioRepository)
        let addPortfolioTransactionUseCase = AddPortfolioTransactionUseCase(repository: portfolioRepository)
        let calculatePortfolioSummaryUseCase = CalculatePortfolioSummaryUseCase(marketRepository: marketRepository, calculator: portfolioSummaryCalculator)
        
        return PortfolioViewModel(
            fetchPortfolioTransactionsUseCase: fetchPortfolioTransactionsUseCase,
            addPortfolioTransactionsUseCase: addPortfolioTransactionUseCase,
            deletePortfolioTransactionsUseCase: deletePortfolioTransactionUseCase,
            calculatePortfolioSummaryUseCase: calculatePortfolioSummaryUseCase
        )
    }
    
    func makeCoinSelectionViewModel() -> CoinSelectionViewModel {
        let searchCryptoUseCase = SearchCryptoUseCase(repository: marketRepository)
        let fetchMarketCoinsUseCase = FetchMarketCoinsUseCase(repository: marketRepository)


        return CoinSelectionViewModel(searchCryptoUseCase: searchCryptoUseCase,fetchMarketCoinsUseCase: fetchMarketCoinsUseCase)
    }
    
    func makeAddTransactionViewModel() -> AddTransactionViewModel {
        let addPortfolioTransactionUseCase = AddPortfolioTransactionUseCase(repository: portfolioRepository)
        
        return AddTransactionViewModel(addPortfolioTransactionUseCase: addPortfolioTransactionUseCase)
    }
    
    func makeDashboardViewModel() -> DashboardViewModel {
        
        let fetchPortfolioTransactionsUseCase = FetchPortfolioTransactionsUseCase(repository: portfolioRepository)
        
        let calculatePortfolioSummaryUseCase = CalculatePortfolioSummaryUseCase(marketRepository: marketRepository, calculator: portfolioSummaryCalculator)
        
        let fetchDashboardDataUseCase = FetchDashboardDataUseCase(
            fetchPortfolioTransactionsUseCase: fetchPortfolioTransactionsUseCase,
            calculatePortfolioSummaryUseCase: calculatePortfolioSummaryUseCase)
        
        return DashboardViewModel(fetchDashboardDataUseCase: fetchDashboardDataUseCase, presentationMapper: dashboardPresentationMapper)
    }
    
    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            userDefaultsManager: UserDefaultsManager.shared// Bağımlılığı veriyoruz
        )
    }
}
