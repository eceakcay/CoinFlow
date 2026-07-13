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
    
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    private enum Keys {
        static let selectedLanguage = "selectedLanguage"
        static let selectedCurrency = "selectedCurrency"
        static let isBiometricEnabled = "isBiometricEnabled"
        static let hasSeenOnboarding = "hasSeenOnboarding"
    }
    
    var selectedLanguage: String {
        get {
            defaults.string(forKey: Keys.selectedLanguage) ?? "en"
        }
        set {
            defaults.set(newValue, forKey: Keys.selectedLanguage)
        }
    }
    
    var selectedCurrency: String {
        get {
            defaults.string(forKey: Keys.selectedCurrency) ?? "usd"
        }
        set {
            defaults.set(newValue, forKey: Keys.selectedCurrency)
        }
    }
    
    var isBiometricEnabled: Bool {
        get {
            defaults.bool(forKey: Keys.isBiometricEnabled)
        }
        set {
            defaults.set(newValue, forKey: Keys.isBiometricEnabled)
        }
    }
    
    var hasSeenOnboarding: Bool {
        get {
            defaults.bool(forKey: Keys.hasSeenOnboarding)
        }
        set {
            defaults.set(newValue, forKey: Keys.hasSeenOnboarding)
        }
    }
}
