//
//  AppCoordinator.swift
//  CoinFlow
//
//  Created by Ece Akcay on 8.07.2026.
//

import UIKit

final class AppCoordinator: Coordinator {
    
    // MARK: - Properties

    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController = UINavigationController()

    private let window: UIWindow
    private let dependencyContainer: DependencyContainer

    // MARK: - Init

    init(window: UIWindow,dependencyContainer: DependencyContainer) {
        self.window = window
        self.dependencyContainer = dependencyContainer
    }
    
    // MARK: - Start

    func start() {

        let isLoggedIn = dependencyContainer.makeCheckFirebaseAuthStatusUseCase().execute()

        let isBiometricEnabled = UserDefaultsManager.shared.isBiometricEnabled

        if isLoggedIn && isBiometricEnabled {

            // Firebase session var ama kullanıcıdan
            // Face ID doğrulaması isteyeceğiz.
            showAuth()

        } else if isLoggedIn {// Session var, Face ID kullanılmıyor.
            showMainTabBar()
        } else {
            showAuth()// Session yok → normal Firebase login.

        }
    }
    // MARK: - Auth

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
    
    // MARK: - Main Tab Bar

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
        
        mainTabBarCoordinator.onAccountDeleted = { [weak self] in
            self?.showAuth()
        }
        
        mainTabBarCoordinator.start()
        
        window.rootViewController = mainTabBarCoordinator.tabBarController
        window.makeKeyAndVisible()
    }
}
