//
//  UserDefaultsManager.swift
//  CoinFlow
//
//  Created by Ece Akcay on 30.06.2026.
//

import Foundation

//uygulamadaki küçük kullanıcı tercihleri burada tutuluyor
final class UserDefaultsManager {
    
    //SİNGLETON PATTERN YAPISI
    static let shared = UserDefaultsManager()
    
    private let userDefaults : UserDefaults
    
    private init(userDefaults : UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    private enum Keys {
        static let selectedLanguage = "selectedLanguage"
        static let selectedCurrency = "selectedCurrency"
        static let isBiometricEnabled = "isBiometricEnabled"
        static let hasSeenOnboarding = "hasSeenOnboarding"
    }
    
    var selectedCurrency: String {
        get {
            userDefaults.string(forKey: Keys.selectedCurrency) ?? "USD" //selectedCurrency yoksa → USD dön
        }
        set {
            userDefaults.set(newValue, forKey: Keys.selectedCurrency)
        }
    }
    
    var selectedLanguage: String {
        get {
            userDefaults.string(forKey: Keys.selectedLanguage) ?? "English" //selectedLanguage yoksa → English dön
        }
        set {
            userDefaults.set(newValue, forKey: Keys.selectedLanguage)
        }
    }
    
    var isBiometricEnabled: Bool {
        get {
            userDefaults.bool(forKey: Keys.isBiometricEnabled)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.isBiometricEnabled)
        }
    }
    
    var hasSeenOnboarding: Bool {
        get {
            userDefaults.bool(forKey: Keys.hasSeenOnboarding)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.hasSeenOnboarding)
        }
    }
}
