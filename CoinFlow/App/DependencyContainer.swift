//
//  DependencyContainer.swift
//  CoinFlow
//
//  Created by Ece Akcay on 8.07.2026.
//

import Foundation

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
    
    func makeMarketViewModel() -> MarketViewModel {
        let fetchUseCase = FetchMarketCoinsUseCase(repository: marketRepository)
        let searchUseCase = SearchCryptoUseCase(repository: marketRepository)
        return MarketViewModel(fetchMarketCoinsUseCase: fetchUseCase,searchCryptoUseCase: searchUseCase
        )
    }
    
    func makeFavoritesViewModel() -> FavoritesViewModel {
        let fetchUseCase = FetchFavoriteCoinsUseCase(favoriteRepository: favoriteRepository, marketRepository: marketRepository)
        let getFavoriteCoinIdsUseCase = GetFavoriteCoinIdsUseCase(repository: favoriteRepository)
        return FavoritesViewModel(fetchFavoriteCoinsUseCase: fetchUseCase, getFavoriteCoinIdsUseCase: getFavoriteCoinIdsUseCase)
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
}
