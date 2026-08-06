//
//  MainTabBarCoordinator.swift
//  CoinFlow
//
//  Created by Ece Akcay on 8.07.2026.
//

import Foundation
import UIKit
import CryptoUI
import SwiftUI

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
        let marketNavigationController = createMarketTab()
        let favoriteNavigationController = createFavoriteTab()
        let profileNavigationController = createProfileTab()
        
        tabBarController.viewControllers = [dashboardNavigationController, portfolioNavigationController, marketNavigationController,favoriteNavigationController, profileNavigationController]
        
        setupTabBarAppearance()
    }
    
    private func createDashboardTab() -> UINavigationController {
        let navigationController = UINavigationController()
        
        let coordinator = DashboardCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        
        coordinator.onExploreMarketTapped = { [weak self] in
            self?.tabBarController.selectedIndex = 2
        }

        coordinator.onSeeAllHoldingsTapped = { [weak self] in
            self?.tabBarController.selectedIndex = 1
        }
         
        coordinator.onSeeAllTransactionsTapped = { [weak self] in
            self?.tabBarController.selectedIndex = 1
        }
        
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
    
    private func createFavoriteTab() -> UINavigationController {
        
        let navigationController = UINavigationController()
        
        let coordinator = FavoritesCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        
        childCoordinators.append(coordinator)
        coordinator.start()
        
        navigationController.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
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
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = CryptoColors.cardBackground

        appearance.stackedLayoutAppearance.selected.iconColor = CryptoColors.positive
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: CryptoColors.positive
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = CryptoColors.tabBarUnselected
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: CryptoColors.tabBarUnselected
        ]

        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance

        tabBarController.tabBar.tintColor = CryptoColors.positive
        tabBarController.tabBar.unselectedItemTintColor = CryptoColors.tabBarUnselected
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.backgroundColor = CryptoColors.cardBackground
    }
}
