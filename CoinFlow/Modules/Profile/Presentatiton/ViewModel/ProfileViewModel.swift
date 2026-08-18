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
        case success
    }
    
    // MARK: - Properties
    
    private let userDefaultsManager: UserDefaultsManager
    private let deleteAllPortfolioTransactionsUseCase : DeleteAllPortfolioTransactionsUseCase
    private let logoutUseCase: FirebaseLogoutUseCase
    
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
        logoutUseCase: FirebaseLogoutUseCase
    ) {
        self.userDefaultsManager = userDefaultsManager
        self.deleteAllPortfolioTransactionsUseCase = deleteAllPortfolioTransactionsUseCase
        self.logoutUseCase = logoutUseCase
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
    
    
}
