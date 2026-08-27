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
    
    let tabBarController = CoinFlowTabBarController()
    
    //Bağımlılıkları kullanabilmek için
    private let dependencyContainer: DependencyContainer
    
    var onLogoutTapped: (() -> Void)?
    var onAccountDeleted: (() -> Void)?
    
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
        let navigationController = CoinFlowNavigationController()
        
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
            title: L10n.text(.dashboard),
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        return navigationController
    }
    
    private func createPortfolioTab() -> UINavigationController {
        let navigationController = CoinFlowNavigationController()
        
        let coordinator = PortfolioCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        
        childCoordinators.append(coordinator)
        coordinator.start()
        
        navigationController.tabBarItem = UITabBarItem(
            title: L10n.text(.portfolio),
            image: UIImage(systemName: "chart.pie"),
            selectedImage: UIImage(systemName: "chart.pie.fill")
        )
        
        return navigationController
        
    }
    
    private func createFavoriteTab() -> UINavigationController {
        
        let navigationController = CoinFlowNavigationController()
        
        let coordinator = FavoritesCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        
        childCoordinators.append(coordinator)
        coordinator.start()
        
        navigationController.tabBarItem = UITabBarItem(
            title: L10n.text(.favorites),
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )
        
        return navigationController
    }
    
    private func createMarketTab() -> UINavigationController {
        
        let navigationController = CoinFlowNavigationController()
        
        let coordinator = MarketCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        
        childCoordinators.append(coordinator)
        coordinator.start()
        
        navigationController.tabBarItem = UITabBarItem(
            title: L10n.text(.market),
            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            selectedImage: UIImage(systemName: "chart.line.uptrend.xyaxis")
        )
        
        return navigationController
    }
    
    private func createProfileTab() -> UINavigationController {
        let navigationController = CoinFlowNavigationController()
        
        let coordinator = ProfileCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        
        coordinator.onLanguageChanged = { [weak self] in
            self?.updateTabBarTitles()
        }
        
        coordinator.onLogoutTapped = { [weak self] in
            self?.onLogoutTapped?()
        }
        
        coordinator.onAccountDeleted = { [weak self] in
            self?.onAccountDeleted?()
        }
        
        childCoordinators.append(coordinator)
        coordinator.start()
        
        navigationController.tabBarItem = UITabBarItem(
            title: L10n.text(.profile),
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        return navigationController
    }
    
    private func updateTabBarTitles() {
        guard let viewControllers = tabBarController.viewControllers else {
            return
        }
        
        viewControllers[0].tabBarItem.title = L10n.text(.dashboard)
        viewControllers[1].tabBarItem.title = L10n.text(.portfolio)
        viewControllers[2].tabBarItem.title = L10n.text(.market)
        viewControllers[3].tabBarItem.title = L10n.text(.favorites)
        viewControllers[4].tabBarItem.title = L10n.text(.profile)
    }
    
    private func setupTabBarAppearance() {
        tabBarController.view.backgroundColor = CryptoColors.appBackground
        tabBarController.viewControllers?
            .compactMap { $0 as? UINavigationController }
            .forEach {
                $0.view.backgroundColor = CryptoColors.appBackground
                $0.navigationBar.barTintColor = CryptoColors.appBackground
            }

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

        appearance.inlineLayoutAppearance.selected.iconColor = CryptoColors.positive
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: CryptoColors.positive,
            .font: UIFont.preferredFont(forTextStyle: .footnote)
        ]
        appearance.inlineLayoutAppearance.normal.iconColor = CryptoColors.tabBarUnselected
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: CryptoColors.primaryText.withAlphaComponent(0.78),
            .font: UIFont.preferredFont(forTextStyle: .footnote)
        ]
        appearance.compactInlineLayoutAppearance.selected.iconColor = CryptoColors.positive
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes =
            appearance.inlineLayoutAppearance.selected.titleTextAttributes
        appearance.compactInlineLayoutAppearance.normal.iconColor = CryptoColors.tabBarUnselected
        appearance.compactInlineLayoutAppearance.normal.titleTextAttributes =
            appearance.inlineLayoutAppearance.normal.titleTextAttributes

        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance

        tabBarController.tabBar.tintColor = CryptoColors.positive
        tabBarController.tabBar.unselectedItemTintColor = CryptoColors.tabBarUnselected
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.backgroundColor = CryptoColors.cardBackground
    }
}
