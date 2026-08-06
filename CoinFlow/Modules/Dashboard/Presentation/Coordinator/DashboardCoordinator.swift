//
//  DashboardCoordinator.swift
//  CoinFlow
//
//  Created by Ece Akcay on 9.07.2026.
//

import Foundation
import UIKit

final class DashboardCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
     var onExploreMarketTapped: (() -> Void)?
     var onSeeAllHoldingsTapped: (() -> Void)?
     var onSeeAllTransactionsTapped: (() -> Void)?
    
    private let dependencyContainer: DependencyContainer
    
    init(navigationController: UINavigationController, dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    func start() {
        let viewModel = dependencyContainer.makeDashboardViewModel()
        let viewController = DashboardViewController(viewModel: viewModel)
        viewController.onAddHoldingTapped = { [weak self] in
            self?.showAddTransaction()
        }
        
        viewController.onExploreMarketTapped = { [weak self] in
            self?.onExploreMarketTapped?()
        }
        
        viewController.onSeeAllHoldingsTapped = { [weak self] in
            self?.onSeeAllHoldingsTapped?()
        }
        
        viewController.onSeeAllHoldingsTransactions = { [weak self] in
            self?.onSeeAllTransactionsTapped?()
        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    private func showAddTransaction() {
        let viewModel = dependencyContainer.makeAddTransactionViewModel()
        let viewController = AddTransactionViewController(viewModel: viewModel)
        
        viewController.onSelectCoinTapped = { [weak self, weak viewController] in
            self?.showCoinSelection { selectedCoin in
                viewController?.setSelectedCoin(selectedCoin) //Coin seçildiğinde seçilen coini AddTransactionVC a geri ver
            }
        }
        
        viewController.onTransactionSaved = { [weak self] in
            self?.navigationController.popViewController(animated: true) //en üstteki stacki çıkar. dashboard ekranına geri dön
        }
        
        navigationController.pushViewController(viewController,animated: true)
    }
    
    private func showCoinSelection(onCoinSelected: @escaping (SelectedPortfolioCoin) -> Void) {
        let viewModel = dependencyContainer.makeCoinSelectionViewModel()
        let viewController = CoinSelectionViewController(viewModel: viewModel)

        viewController.onCoinSelected = { [weak self] coin in
            let selectedCoin = SelectedPortfolioCoin(
                id: coin.id,
                name: coin.name,
                symbol: coin.symbol
            )

            onCoinSelected(selectedCoin)

            self?.navigationController.popViewController(animated: true)
        }

        navigationController.pushViewController(viewController,animated: true)
    }
}

