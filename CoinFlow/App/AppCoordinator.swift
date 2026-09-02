//
//  AppCoordinator.swift
//  CoinFlow
//
//  Created by Ece Akcay on 8.07.2026.
//

import UIKit
import CryptoUI

final class AppCoordinator: Coordinator {
    
    // MARK: - Properties

    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController = CoinFlowNavigationController()

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
            showBiometricLock()

        } else if isLoggedIn {
            synchronizeAndShowMain()
        } else if UserDefaultsManager.shared.isGuestMode {
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
        applyRootAppearance(to: onboardingCoordinator.navigationController)
        window.makeKeyAndVisible()
    }
    // MARK: - Auth

    private func showAuth() {
        childCoordinators.removeAll()

        let authNavigationController = CoinFlowNavigationController()

        let authCoordinator = AuthCoordinator(
            navigationController: authNavigationController,
            dependencyContainer: dependencyContainer
        )

        authCoordinator.onLoginSuccess = { [weak self] in
            UserDefaultsManager.shared.isGuestMode = false
            self?.synchronizeAndShowMain()
        }

        authCoordinator.onGuestModeSelected = { [weak self] in
            guard let self,
                  self.dependencyContainer.signOutForGuestMode() else { return }
            PortfolioWidgetSnapshotStore.clear()
            UserDefaultsManager.shared.isGuestMode = true
            UserDefaultsManager.shared.isBiometricEnabled = false
            UserDefaultsManager.shared.clearCurrentUserInfo()
            self.showMainTabBar()
        }

        childCoordinators.append(authCoordinator)

        authCoordinator.start()

        window.rootViewController = authNavigationController
        applyRootAppearance(to: authNavigationController)
        window.makeKeyAndVisible()
    }

    private func showBiometricLock() {
        childCoordinators.removeAll()

        let lockNavigationController = CoinFlowNavigationController()
        lockNavigationController.setNavigationBarHidden(true, animated: false)
        let lockViewController = BiometricLockViewController(
            viewModel: dependencyContainer.makeFirebaseLoginViewModel()
        )
        lockViewController.onUnlock = { [weak self] in
            self?.synchronizeAndShowMain()
        }
        lockViewController.onUsePassword = { [weak self] in
            self?.showAuth()
        }
        lockNavigationController.setViewControllers([lockViewController], animated: false)

        window.rootViewController = lockNavigationController
        applyRootAppearance(to: lockNavigationController)
        window.makeKeyAndVisible()
    }

    private func synchronizeAndShowMain() {
        Task { [weak self] in
            guard let self else { return }
            await dependencyContainer.synchronizeCloudData()
            await MainActor.run { self.showMainTabBar() }
        }
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
        applyRootAppearance(to: mainTabBarCoordinator.tabBarController)
        window.makeKeyAndVisible()
    }

    private func applyRootAppearance(to rootViewController: UIViewController) {
        window.backgroundColor = CryptoColors.appBackground
        rootViewController.view.backgroundColor = CryptoColors.appBackground
        rootViewController.setNeedsStatusBarAppearanceUpdate()

        if let navigationController = rootViewController as? UINavigationController {
            navigationController.view.backgroundColor = CryptoColors.appBackground
            navigationController.navigationBar.barTintColor = CryptoColors.appBackground
        }
    }
}
