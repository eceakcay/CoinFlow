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
    
    private(set) var sections: [ProfileSection] = []
    
    var onStateChange: ((State) -> Void)?
    
    var selectedCurrency: String {
        userDefaultsManager.selectedCurrency
    }
    
    var selectedLanguage: String {
        userDefaultsManager.selectedLanguage
    }
    
    // MARK: - Init
    
    init(userDefaultsManager: UserDefaultsManager) {
        self.userDefaultsManager = userDefaultsManager
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
        userDefaultsManager.selectedLanguage = language
        loadSections()
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
            title: "Preferences",
            items: [
                ProfileRowItem(
                    title: "Currency",
                    subtitle: userDefaultsManager.selectedCurrency,
                    systemImageName: "dollarsign.circle",
                    type: .currency,
                    accessoryType: .chevron,
                    isDestructive: false
                ),
                ProfileRowItem(
                    title: "Language",
                    subtitle: userDefaultsManager.selectedLanguage,
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
            title: "Security",
            items: [
                ProfileRowItem(
                    title: "Biometric Login",
                    subtitle: "Face ID / Touch ID",
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
            title: "App",
            items: [
                ProfileRowItem(
                    title: "App Info",
                    subtitle: "CoinFlow v1.0",
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
            title: "Danger Zone",
            items: [
                ProfileRowItem(
                    title: "Reset Portfolio Data",
                    subtitle: "Delete all saved transactions",
                    systemImageName: "trash",
                    type: .resetPortfolio,
                    accessoryType: .chevron,
                    isDestructive: true
                )
            ]
        )
    }
}
