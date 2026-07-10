//
//  AppCoordinator.swift
//  CoinFlow
//
//  Created by Ece Akcay on 8.07.2026.
//

import UIKit

final class AppCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController = UINavigationController()
    
    private let window: UIWindow
    private let dependencyContainer: DependencyContainer
    
    init(window: UIWindow,dependencyContainer: DependencyContainer) {
        self.window = window
        self.dependencyContainer = dependencyContainer
    }
    
    func start() {
        showMainTabBar()
    }
    
    private func showMainTabBar() {
        let mainTabBarCoordinator = MainTabBarCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        
        childCoordinators.append(mainTabBarCoordinator)
        
        mainTabBarCoordinator.start()
        
        window.rootViewController = mainTabBarCoordinator.tabBarController
        window.makeKeyAndVisible()
    }
}
