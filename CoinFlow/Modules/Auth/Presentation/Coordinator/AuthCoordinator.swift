//
//  AuthCoordinator.swift
//  CoinFlow
//
//  Created by Ece Akcay on 12.08.2026.
//

import Foundation
import UIKit

final class AuthCoordinator: Coordinator {

    // MARK: - Properties

    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    var onLoginSuccess: (() -> Void)?

    private let dependencyContainer: DependencyContainer

    // MARK: - Init

    init(
        navigationController: UINavigationController,
        dependencyContainer: DependencyContainer
    ) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }

    // MARK: - Start

    func start() {
        let viewModel = dependencyContainer.makeFirebaseLoginViewModel()
        let viewController = FirebaseLoginViewController(viewModel: viewModel)

        viewController.onLoginSuccess = { [weak self] in
            self?.onLoginSuccess?()
        }
        
        viewController.onCreateAccountTapped = { [weak self] in
            self?.showRegister()
        }

        navigationController.setViewControllers([viewController],animated: false)
    }
    
    private func showLogin() {
        let viewModel = dependencyContainer.makeFirebaseLoginViewModel()
        let viewController = FirebaseLoginViewController(viewModel: viewModel)

        viewController.onLoginSuccess = { [weak self] in
            self?.onLoginSuccess?()
        }

        viewController.onCreateAccountTapped = { [weak self] in
            self?.showRegister()
        }

        navigationController.setViewControllers([viewController], animated: true)
    }
    
    private func showRegister() {
        let viewModel = dependencyContainer.makeRegisterViewModel()
        let viewController = RegisterViewController(viewModel: viewModel)

        viewController.onRegisterSuccess = { [weak self] in
            self?.onLoginSuccess?()
        }

        navigationController.pushViewController(viewController, animated: true)
    }
}
