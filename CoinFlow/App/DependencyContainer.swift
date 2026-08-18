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
    
  //  private lazy var authAPIService: AuthAPIService = {
  //      return AuthAPIService(apiClient: apiClient)
  //  }()
    
    private lazy var marketRepository: MarketRepositoryProtocol = {
        return MarketRepositoryImpl(service: marketAPIService)
    }()
    
    private lazy var favoriteRepository: FavoriteRepositoryProtocol = {
        return FavoriteRepositoryImpl(localDataSource: favoriteLocalDataSource)
    }()
    
   // private lazy var authRepository: AuthRepositoryProtocol = {
   //     return AuthRepositoryImpl(service: authAPIService,keychainManager: KeychainManager.shared)
   // }()
    
    private lazy var firebaseAuthService: FirebaseAuthService = {
        FirebaseAuthService()
    }()

    private lazy var firebaseAuthRepository: FirebaseAuthRepositoryProtocol = {
        FirebaseAuthRepositoryImpl(
            firebaseAuthService: firebaseAuthService,
            userDefaultsManager: UserDefaultsManager.shared
        )
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
        let removeUseCase = RemoveFavoriteCoinUseCase(repository: favoriteRepository)
        let getFavoriteUseCase = GetFavoriteCoinIdsUseCase(repository: favoriteRepository)
        let userDefaultsManager = UserDefaultsManager.shared
        
        return MarketViewModel(
            fetchMarketCoinsUseCase: fetchUseCase,
            searchCryptoUseCase: searchUseCase,
            removeFavoriteCoinUseCase: removeUseCase,
            userDefaultsManager: userDefaultsManager,
            getFavoriteCoinIdsUseCase: getFavoriteUseCase
        )
    }
    
    func makeFavoritesViewModel() -> FavoritesViewModel {
        let fetchUseCase = FetchFavoriteCoinsUseCase(favoriteRepository: favoriteRepository, marketRepository: marketRepository)
        let getFavoriteCoinIdsUseCase = GetFavoriteCoinIdsUseCase(repository: favoriteRepository)
        let removeFavoriteCoinUseCase = RemoveFavoriteCoinUseCase(repository: favoriteRepository)
        let userDefaultsManager = UserDefaultsManager.shared
        return FavoritesViewModel(fetchFavoriteCoinsUseCase: fetchUseCase, getFavoriteCoinIdsUseCase: getFavoriteCoinIdsUseCase, removeFavoriteCoinUseCase: removeFavoriteCoinUseCase, userDefaultsManager: userDefaultsManager)
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
        
        let userDefaultsManager = UserDefaultsManager.shared

        return CryptoDetailViewModel(
            coin: coin,
            isFavoriteCoinUseCase: isFavoriteCoinUseCase,
            toggleFavoriteCoinUseCase: toggleFavoriteCoinUseCase,
            fetchCoinChartUseCase: fetchCoinChartUseCase,
            userDefaultsManager: userDefaultsManager
        )
    }
    
    func makePortfolioViewModel() -> PortfolioViewModel {
        let fetchPortfolioTransactionsUseCase = FetchPortfolioTransactionsUseCase(repository: portfolioRepository)
        let deletePortfolioTransactionUseCase = DeletePortfolioTransactionUseCase(repository: portfolioRepository)
        let addPortfolioTransactionUseCase = AddPortfolioTransactionUseCase(repository: portfolioRepository)
        let calculatePortfolioSummaryUseCase = CalculatePortfolioSummaryUseCase(marketRepository: marketRepository, calculator: portfolioSummaryCalculator)
        let userDefaultsManager = UserDefaultsManager.shared
        
        return PortfolioViewModel(
            fetchPortfolioTransactionsUseCase: fetchPortfolioTransactionsUseCase,
            addPortfolioTransactionsUseCase: addPortfolioTransactionUseCase,
            deletePortfolioTransactionsUseCase: deletePortfolioTransactionUseCase,
            calculatePortfolioSummaryUseCase: calculatePortfolioSummaryUseCase,
            userDefaultsManager: userDefaultsManager
        )
    }
    
    func makeCoinSelectionViewModel() -> CoinSelectionViewModel {
        let searchCryptoUseCase = SearchCryptoUseCase(repository: marketRepository)
        let fetchMarketCoinsUseCase = FetchMarketCoinsUseCase(repository: marketRepository)
        let userDefaultsManager = UserDefaultsManager.shared


        return CoinSelectionViewModel(searchCryptoUseCase: searchCryptoUseCase,fetchMarketCoinsUseCase: fetchMarketCoinsUseCase, userDefaultsManager: userDefaultsManager)
    }
    
    func makeAddTransactionViewModel() -> AddTransactionViewModel {
        let addPortfolioTransactionUseCase = AddPortfolioTransactionUseCase(
            repository: portfolioRepository
        )

        return AddTransactionViewModel(
            addPortfolioTransactionUseCase: addPortfolioTransactionUseCase
        )
    }
    
    func makeDashboardViewModel() -> DashboardViewModel {
        
        let fetchPortfolioTransactionsUseCase = FetchPortfolioTransactionsUseCase(repository: portfolioRepository)
        
        let calculatePortfolioSummaryUseCase = CalculatePortfolioSummaryUseCase(marketRepository: marketRepository, calculator: portfolioSummaryCalculator)
        
        let fetchDashboardDataUseCase = FetchDashboardDataUseCase(
            fetchPortfolioTransactionsUseCase: fetchPortfolioTransactionsUseCase,
            calculatePortfolioSummaryUseCase: calculatePortfolioSummaryUseCase)
        
        let userDefaultsManager = UserDefaultsManager.shared

        return DashboardViewModel(fetchDashboardDataUseCase: fetchDashboardDataUseCase, presentationMapper: dashboardPresentationMapper, userDefaultsManager: userDefaultsManager)
    }
    
    func makeProfileViewModel() -> ProfileViewModel {
        
        let deleteAllPortfolioTransactionsUseCase = DeleteAllPortfolioTransactionsUseCase(repository: portfolioRepository)
                
        let logoutUseCase = FirebaseLogoutUseCase(repository: firebaseAuthRepository)
                
        return ProfileViewModel(
            userDefaultsManager: UserDefaultsManager.shared,
            deleteAllPortfolioTransactionsUseCase: deleteAllPortfolioTransactionsUseCase,
            logoutUseCase: logoutUseCase
        )
    }
        
    func makeRegisterViewModel() -> RegisterViewModel {
        let firebaseRegisterUseCase = FirebaseRegisterUseCase(
            repository: firebaseAuthRepository
        )

        return RegisterViewModel(
            firebaseRegisterUseCase: firebaseRegisterUseCase
        )
    }
    
    func makeFirebaseLoginViewModel()-> FirebaseLoginViewModel {

        let firebaseLoginUseCase = FirebaseLoginUseCase(repository:firebaseAuthRepository)

        let checkFirebaseAuthStatusUseCase = CheckFirebaseAuthStatusUseCase(repository:firebaseAuthRepository)

        let authenticateWithBiometricsUseCase = AuthenticateWithBiometricsUseCase(biometricAuthManager:BiometricAuthManager.shared)
        
        let firebasePasswordResetUseCase = FirebasePasswordResetUseCase(repository:firebaseAuthRepository)

        return FirebaseLoginViewModel(
            firebaseLoginUseCase: firebaseLoginUseCase,
            checkFirebaseAuthStatusUseCase: checkFirebaseAuthStatusUseCase,
            authenticateWithBiometricsUseCase: authenticateWithBiometricsUseCase,
            userDefaultsManager: UserDefaultsManager.shared,
            firebasePasswordResetUseCase: firebasePasswordResetUseCase,
        )
    }
    

    func makeCheckFirebaseAuthStatusUseCase() -> CheckFirebaseAuthStatusUseCase {
        CheckFirebaseAuthStatusUseCase(repository: firebaseAuthRepository)
    }
}
