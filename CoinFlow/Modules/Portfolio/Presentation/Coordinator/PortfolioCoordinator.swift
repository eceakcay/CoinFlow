//
//  PortfolioCoordinator.swift
//  CoinFlow
//
//  Created by Ece Akcay on 9.07.2026.
//

import Foundation
import UIKit

final class PortfolioCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let dependencyContainer : DependencyContainer
    
    init(navigationController: UINavigationController, dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    func start() {
        let viewModel = dependencyContainer.makePortfolioViewModel()
        let viewController = PortfolioViewController(viewModel: viewModel)
        
        viewController.onAddTransactionTapped = { [weak self] in
            self?.showAddTransaction() //portföy işlemi ekleme ekranını açıyor.
        }
        
        navigationController.setViewControllers([viewController], animated: false) //ilk ekran, başlangıç ekranı
    }
    
    //işlem ekleme ekranı açıyor
    private func showAddTransaction() {
        let viewModel = dependencyContainer.makeAddTransactionViewModel()
        let viewController = AddTransactionViewController(viewModel: viewModel)
        
        viewController.onSelectCoinTapped = { [weak self, weak viewController] in
            self?.showCoinSelection { selectedCoin in
                viewController?.setSelectedCoin(selectedCoin) //Coin seçildiğinde seçilen coini AddTransactionVC a geri ver
            }
        }
        
        viewController.onTransactionSaved = { [weak self] in
            self?.navigationController.popViewController(animated: true) //en üstteki stacki çıkar. portfolio ekranına geri dön
        }
        
        navigationController.pushViewController(viewController,animated: true)
    }
    
    //coin seçme ekranı açıyor
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
