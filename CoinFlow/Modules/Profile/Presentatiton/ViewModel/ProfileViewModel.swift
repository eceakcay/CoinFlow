//
//  ProfileViewModel.swift
//  CoinFlow
//
//  Created by Ece Akcay on 6.08.2026.
//

import Foundation
import UIKit

final class ProfileViewModel {
    
    // MARK: - State
    
    enum State {
        case idle
        case loading
        case success
        case accountDeleted
        case failure(String)
    }
    
    // MARK: - Properties
    
    private let userDefaultsManager: UserDefaultsManager
    private let deleteAllPortfolioTransactionsUseCase : DeleteAllPortfolioTransactionsUseCase
    private let logoutUseCase: FirebaseLogoutUseCase
    private let deleteUserAccountUseCase: DeleteUserAccountUseCase
    
    private(set) var sections: [ProfileSection] = []
    
    var onStateChange: ((State) -> Void)?
    
    var selectedCurrency: String {
        userDefaultsManager.selectedCurrency
    }
    
    var selectedLanguage: String {
        let currentLanguage = userDefaultsManager.appLanguage
        return currentLanguage.displayName(in: currentLanguage)
    }
    
    var userDisplayName: String {
        if let fullName = userDefaultsManager.currentUserFullName,
           !fullName.isEmpty {
            return fullName
        }

        if let username = userDefaultsManager.currentUsername,
           !username.isEmpty {
            return username
        }

        return "CoinFlow User"
    }

    var userInitialText: String {
        String(userDisplayName.prefix(1)).uppercased()
    }
    
    // MARK: - Init
    
    init(
        userDefaultsManager: UserDefaultsManager,
        deleteAllPortfolioTransactionsUseCase: DeleteAllPortfolioTransactionsUseCase,
        logoutUseCase: FirebaseLogoutUseCase,
        deleteUserAccountUseCase: DeleteUserAccountUseCase
    ) {
        self.userDefaultsManager = userDefaultsManager
        self.deleteAllPortfolioTransactionsUseCase = deleteAllPortfolioTransactionsUseCase
        self.logoutUseCase = logoutUseCase
        self.deleteUserAccountUseCase = deleteUserAccountUseCase
    }
    
    // MARK: - Lifecycle
    
    func viewDidLoad() {
        loadSections()
    }
    
    // MARK: - Actions
    
    func setBiometricEnabled(_ isEnabled: Bool) {
        userDefaultsManager.isBiometricEnabled = isEnabled
        sections = makeSections()

    }
    
    func updateCurrency(_ currency: String) {
        userDefaultsManager.selectedCurrency = currency
        loadSections()
    }
    
    func updateLanguage(_ language: String) {
        userDefaultsManager.appLanguage = AppLanguage(value: language)
        loadSections()
    }
    
    func resetPortfolioData() throws {
        try deleteAllPortfolioTransactionsUseCase.execute()
    }
    
    func logout() throws {
        try logoutUseCase.execute()
    }
    
    func deleteAccount(password: String) {

        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedPassword.isEmpty else {

            onStateChange?(.failure(L10n.text(.passwordRequired)))

            return
        }

        onStateChange?(.loading)

        Task { [weak self] in

            guard let self else {
                return
            }

            do {

                try await deleteUserAccountUseCase.execute(
                    password: trimmedPassword
                )

                await MainActor.run {
                    self.onStateChange?(.accountDeleted)
                }

            } catch {

                let message =
                    deleteAccountErrorMessage(
                        for: error
                    )

                await MainActor.run {
                    self.onStateChange?(
                        .failure(message)
                    )
                }
            }
        }
    }
    
    // MARK: - Section Helpers
    
    func numberOfSections() -> Int {
        sections.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        guard sections.indices.contains(section) else {
            return 0
        }
        
        return sections[section].items.count
    }
    
    func sectionTitle(at section: Int) -> String? {
        guard sections.indices.contains(section) else {
            return nil
        }
        
        return sections[section].title
    }
    
    func item(at indexPath: IndexPath) -> ProfileRowItem? {
        guard sections.indices.contains(indexPath.section),
              sections[indexPath.section].items.indices.contains(indexPath.row) else {
            return nil
        }
        
        return sections[indexPath.section].items[indexPath.row]
    }
    
    // MARK: - Private Methods
    
    private func loadSections() {
        sections = makeSections()
        onStateChange?(.success)
    }
    
    private func makeSections() -> [ProfileSection] {
        [
            makePreferencesSection(),
            makeSecuritySection(),
            makeAppSection(),
            makeDangerZoneSection()
        ]
    }
    
    private func makePreferencesSection() -> ProfileSection {
        ProfileSection(
            title: L10n.text(.preferences),
            items: [
                ProfileRowItem(
                    title: L10n.text(.currency),
                    subtitle: userDefaultsManager.selectedCurrency,
                    systemImageName: "dollarsign.circle",
                    type: .currency,
                    accessoryType: .chevron,
                    isDestructive: false
                ),
                ProfileRowItem(
                    title: L10n.text(.language),
                    subtitle: userDefaultsManager.appLanguage.displayName(
                        in: userDefaultsManager.appLanguage
                    ),
                    systemImageName: "globe",
                    type: .language,
                    accessoryType: .chevron,
                    isDestructive: false
                )
            ]
        )
    }
    
    private func makeSecuritySection() -> ProfileSection {
        ProfileSection(
            title: L10n.text(.security),
            items: [
                ProfileRowItem(
                    title: L10n.text(.biometricLogin),
                    subtitle: L10n.text(.biometricSubtitle),
                    systemImageName: "faceid",
                    type: .biometric,
                    accessoryType: .toggle(isOn: userDefaultsManager.isBiometricEnabled),
                    isDestructive: false
                )
            ]
        )
    }
    
    private func makeAppSection() -> ProfileSection {
        ProfileSection(
            title: L10n.text(.app),
            items: [
                ProfileRowItem(
                    title: L10n.text(.appInfo),
                    subtitle: L10n.text(.appInfoSubtitle),
                    systemImageName: "info.circle",
                    type: .appInfo,
                    accessoryType: .chevron,
                    isDestructive: false
                )
            ]
        )
    }
    
    private func makeDangerZoneSection() -> ProfileSection {
        ProfileSection(
            title: L10n.text(.dangerZone),
            items: [
                ProfileRowItem(
                    title: L10n.text(.resetPortfolioData),
                    subtitle: L10n.text(.resetPortfolioSubtitle),
                    systemImageName: "trash",
                    type: .resetPortfolio,
                    accessoryType: .chevron,
                    isDestructive: true
                ),
                ProfileRowItem(
                    title: L10n.text(.deleteAccount),
                    subtitle: L10n.text(.deleteAccountSubtitle),
                    systemImageName: "person.crop.circle.badge.minus",
                    type: .deleteAccount,
                    accessoryType: .chevron,
                    isDestructive: true
                ),
                ProfileRowItem(
                    title: L10n.text(.logout),
                    subtitle: L10n.text(.logoutSubtitle),
                    systemImageName: "rectangle.portrait.and.arrow.right",
                    type: .logout,
                    accessoryType: .chevron,
                    isDestructive: true
                )
            ]
        )
    }
    
    private func deleteAccountErrorMessage(for error: Error) -> String {

        guard let authError = error as? AuthError else {
            return L10n.text(.deleteAccountFailed)
        }

        switch authError {

        case .invalidPassword:
            return L10n.text(.invalidPassword)

        case .requiresRecentLogin:
            return L10n.text(.requiresRecentLogin)

        case .userNotFound:
            return L10n.text(.userNotFound)

        case .deleteAccountFailed:
            return L10n.text(.deleteAccountFailed)

        case .invalidCredentials,
             .keychainSaveFailed,
             .logoutFailed,
             .loginFailed,
             .unknown:

            return L10n.text(.deleteAccountFailed)
        }
    }
    
    
}
