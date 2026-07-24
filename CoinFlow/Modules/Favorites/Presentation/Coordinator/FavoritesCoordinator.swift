//
//  TradeCoordinator.swift
//  CoinFlow
//
//  Created by Ece Akcay on 9.07.2026.
//

import Foundation
import UIKit

final class FavoritesCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let dependencyContainer: DependencyContainer
    
    init(navigationController: UINavigationController, dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    func start() {
        let viewModel = dependencyContainer.makeFavoritesViewModel()
        let viewController = FavoritesViewController(viewModel: viewModel)
        viewController.onCoinSelected = { [weak self] coin in
            self?.showCryptoDetail(coin: coin)
        }
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showCryptoDetail(coin: CryptoCurrency) {
        let viewModel = dependencyContainer.makeCryptoDetailViewModel(coin: coin)
        let viewController = CryptoDetailViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    
}
