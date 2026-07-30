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
        navigationController.setViewControllers([viewController], animated: false)
        
        viewController.onAddTransactionTapped = { [weak self] in
            self?.showAddTransaction()
        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    private func showAddTransaction() {
        print("Add transaction tapped")
    }
    
    
}
