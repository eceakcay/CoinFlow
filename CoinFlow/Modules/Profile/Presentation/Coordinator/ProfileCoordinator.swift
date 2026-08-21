//
//  ProfileCoordinator.swift
//  CoinFlow
//
//  Created by Ece Akcay on 9.07.2026.
//

import Foundation
import UIKit

final class ProfileCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    var onLanguageChanged: (() -> Void)?
    var onLogoutTapped: (() -> Void)?
    var onAccountDeleted: (() -> Void)?
    
    private let dependencyContainer: DependencyContainer
    
    init(navigationController: UINavigationController, dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    
    func start() {
        let viewModel = dependencyContainer.makeProfileViewModel()
        let viewController = ProfileViewController(viewModel: viewModel)
        
        viewController.onCurrencyTapped = { [weak self, weak viewModel] in
            guard let viewModel else { return }
            
            self?.showCurrencySelection(
                selectedCurrency: viewModel.selectedCurrency,
                onSelected: { currency in
                    viewModel.updateCurrency(currency)
                }
            )
        }
        
        viewController.onLanguageTapped = { [weak self, weak viewModel] in
            guard let viewModel else { return }
            
            self?.showLanguageSelection(
                selectedLanguage: viewModel.selectedLanguage,
                onSelected: { [weak self] language in
                    viewModel.updateLanguage(language)
                    self?.onLanguageChanged?()
                }
            )
        }
        
        viewController.onLogoutTapped = { [weak self] in
            self?.onLogoutTapped?()
        }
        
        viewController.onAccountDeleted = { [weak self] in
            self?.onAccountDeleted?()
        }

        viewController.onSignInTapped = { [weak self] in
            self?.onLogoutTapped?()
        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    private func showCurrencySelection(selectedCurrency: String,onSelected: @escaping (String) -> Void) {
        let viewController = ProfileSelectionViewController(
            title: L10n.text(.currency),
            options: ["USD", "EUR", "TRY"],
            selectedValue: selectedCurrency,
            descriptionText: L10n.text(.currencySelectionDescription)
        )
        
        viewController.onOptionSelected = { [weak self] currency in
            onSelected(currency)
            self?.navigationController.popViewController(animated: true)
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showLanguageSelection(selectedLanguage: String, onSelected: @escaping (String) -> Void) {
        let currentLanguage = UserDefaultsManager.shared.appLanguage

        let languageOptions = AppLanguage.allCases.map {
            $0.displayName(in: currentLanguage)
        }
        
        let viewController = ProfileSelectionViewController(
            title: L10n.text(.language),
            options: languageOptions,
            selectedValue: selectedLanguage,
            descriptionText: L10n.text(.languageSelectionDescription)
        )
        
        viewController.onOptionSelected = { [weak self] language in
            onSelected(language)
            self?.navigationController.popViewController(animated: true)
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
