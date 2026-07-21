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
    
    func makeMarketViewModel() -> MarketViewModel {
        let fetchUseCase = FetchMarketCoinsUseCase(repository: marketRepository)
        let searchUseCase = SearchCryptoUseCase(repository: marketRepository)
        return MarketViewModel(
            fetchMarketCoinsUseCase: fetchUseCase,
            searchCryptoUseCase: searchUseCase
        )
    }
    
    private lazy var favoriteLocalDataSource: FavoriteLocalDataSource = {
        return FavoriteLocalDataSource()
    }()

    private lazy var favoriteRepository: FavoriteRepositoryProtocol = {
        return FavoriteRepositoryImpl(localDataSource: favoriteLocalDataSource)
    }()
    
    func makeCryptoDetailViewModel(coin: CryptoCurrency) -> CryptoDetailViewModel {
        let isFavoriteCoinUseCase = IsFavoriteCoinUseCase(
            repository: favoriteRepository
        )

        let toggleFavoriteCoinUseCase = ToggleFavoriteCoinUseCase(
            repository: favoriteRepository
        )

        return CryptoDetailViewModel(coin: coin,isFavoriteCoinUseCase: isFavoriteCoinUseCase,toggleFavoriteCoinUseCase: toggleFavoriteCoinUseCase
        )
    }
}
