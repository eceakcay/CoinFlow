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

        guard UserDefaultsManager.shared.hasSeenOnboarding else {
            showOnboarding()
            return
        }

        showInitialFlow()
    }

    private func showInitialFlow() {

        let isLoggedIn = dependencyContainer.makeCheckFirebaseAuthStatusUseCase().execute()

        let isBiometricEnabled = UserDefaultsManager.shared.isBiometricEnabled

        if isLoggedIn && isBiometricEnabled {

            // Firebase session var ama kullanıcıdan
            // Face ID doğrulaması isteyeceğiz.
            showAuth()

        } else if isLoggedIn || UserDefaultsManager.shared.isGuestMode {// Session var veya misafir kullanım seçilmiş.
            showMainTabBar()
        } else {
            showAuth()// Session yok → normal Firebase login.

        }
    }

    private func showOnboarding() {
        childCoordinators.removeAll()

        let onboardingCoordinator = OnboardingCoordinator()
        onboardingCoordinator.onFinished = { [weak self] in
            UserDefaultsManager.shared.hasSeenOnboarding = true
            self?.showInitialFlow()
        }

        childCoordinators.append(onboardingCoordinator)
        onboardingCoordinator.start()

        window.rootViewController = onboardingCoordinator.navigationController
        window.makeKeyAndVisible()
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
            UserDefaultsManager.shared.isGuestMode = false
            self?.showMainTabBar()
        }

        authCoordinator.onGuestModeSelected = { [weak self] in
            UserDefaultsManager.shared.isGuestMode = true
            UserDefaultsManager.shared.isBiometricEnabled = false
            UserDefaultsManager.shared.clearCurrentUserInfo()
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
            UserDefaultsManager.shared.isGuestMode = false
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
