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
        let viewModel = dependencyContainer.makeLoginViewModel()
        let viewController = LoginViewController(viewModel: viewModel)

        viewController.onLoginSuccess = { [weak self] in
            self?.onLoginSuccess?()
        }

        navigationController.setViewControllers(
            [viewController],
            animated: false
        )
    }
}
