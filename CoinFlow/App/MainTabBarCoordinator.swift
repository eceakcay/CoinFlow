//
//  MainTabBarCoordinator.swift
//  CoinFlow
//
//  Created by Ece Akcay on 8.07.2026.
//

import Foundation
import UIKit

final class MainTabBarCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    
    //Ekran geçişleri için
    var navigationController: UINavigationController
    
    let tabBarController = UITabBarController()
    
    //Bağımlılıkları kullanabilmek için
    private let dependencyContainer: DependencyContainer
    
    init(navigationController: UINavigationController, dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    func start() {
        let dashboardNavigationController = createDashboardTab()
        let portfolioNavigationController = createPortfolioTab()
        let tradeNavigationController = createTradeTab()
        let marketNavigationController = createMarketTab()
        let profileNavigationController = createProfileTab()
        
        tabBarController.viewControllers = [dashboardNavigationController, portfolioNavigationController, tradeNavigationController, marketNavigationController, profileNavigationController]
        
        tabBarController.tabBar.backgroundColor = .systemBackground
        tabBarController.tabBar.tintColor = .systemBlue
        
    }
    
    private func createDashboardTab() -> UINavigationController {
        let navigationController = UINavigationController()
        
        let coordinator = DashboardCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        
        childCoordinators.append(coordinator)
        coordinator.start()
        
        navigationController.tabBarItem = UITabBarItem(
            title: "Dashboard",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        return navigationController
    }
    
    private func createPortfolioTab() -> UINavigationController {
        let navigationController = UINavigationController()
        
        let coordinator = PortfolioCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        
        childCoordinators.append(coordinator)
        coordinator.start()
        
        navigationController.tabBarItem = UITabBarItem(
            title: "Portfolio",
            image: UIImage(systemName: "chart.pie"),
            selectedImage: UIImage(systemName: "chart.pie.fill")
        )
        
        return navigationController
        
    }
    
    private func createTradeTab() -> UINavigationController {
        
        let navigationController = UINavigationController()
        
        let coordinator = TradeCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        
        childCoordinators.append(coordinator)
        coordinator.start()
        
        navigationController.tabBarItem = UITabBarItem(
            title: "Trade",
            image: UIImage(systemName: "arrow.left.arrow.right.circle"),
            selectedImage: UIImage(systemName: "arrow.left.arrow.right.circle.fill")
        )
        
        return navigationController
    }
    
    private func createMarketTab() -> UINavigationController {
        
        let navigationController = UINavigationController()
        
        let coordinator = MarketCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        
        childCoordinators.append(coordinator)
        coordinator.start()
        
        navigationController.tabBarItem = UITabBarItem(
            title: "Market",
            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            selectedImage: UIImage(systemName: "chart.line.uptrend.xyaxis")
        )
        
        return navigationController
    }
    
    private func createProfileTab() -> UINavigationController {
        let navigationController = UINavigationController()
        
        let coordinator = ProfileCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        
        childCoordinators.append(coordinator)
        coordinator.start()
        
        navigationController.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        return navigationController
    }
}
