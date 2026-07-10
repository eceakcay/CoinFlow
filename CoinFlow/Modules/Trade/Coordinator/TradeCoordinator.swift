//
//  TradeCoordinator.swift
//  CoinFlow
//
//  Created by Ece Akcay on 9.07.2026.
//

import Foundation
import UIKit

final class TradeCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let DependencyContainer: DependencyContainer
    
    init(navigationController: UINavigationController, dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.DependencyContainer = dependencyContainer
    }
    
    func start() {
        let viewController = TradeViewController()
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    
}
