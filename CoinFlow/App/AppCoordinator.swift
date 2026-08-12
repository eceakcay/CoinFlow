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
        let isLoggedIn = dependencyContainer.makeCheckAuthStatusUseCase().execute()

        let isBiometricEnabled = UserDefaultsManager.shared.isBiometricEnabled

        print("App start - Token var mı:", isLoggedIn)
        print("App start - Biometric açık mı:", isBiometricEnabled)

        if isLoggedIn && isBiometricEnabled {
            showAuth()
        } else if isLoggedIn {
            showMainTabBar()
        } else {
            showAuth()
        }
    }

    private func showAuth() {
        childCoordinators.removeAll()

        let authNavigationController = UINavigationController()

        let authCoordinator = AuthCoordinator(
            navigationController: authNavigationController,
            dependencyContainer: dependencyContainer
        )

        authCoordinator.onLoginSuccess = { [weak self] in
            self?.showMainTabBar()
        }

        childCoordinators.append(authCoordinator)

        authCoordinator.start()

        window.rootViewController = authNavigationController
        window.makeKeyAndVisible()
    }

    private func showMainTabBar() {
        childCoordinators.removeAll()

        let mainTabBarCoordinator = MainTabBarCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        
        childCoordinators.append(mainTabBarCoordinator)
        
        mainTabBarCoordinator.onLogoutTapped = { [weak self] in
            self?.showAuth()
        }
        
        mainTabBarCoordinator.start()
        
        window.rootViewController = mainTabBarCoordinator.tabBarController
        window.makeKeyAndVisible()
    }
}
