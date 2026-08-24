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

    private static let guestDataOwnerId = "coinflow.local.guest"
    
    private let userDefaults : UserDefaults
    
    private init(userDefaults : UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    private enum Keys {
        static let selectedLanguage = "selectedLanguage"
        static let selectedCurrency = "selectedCurrency"
        static let isBiometricEnabled = "isBiometricEnabled"
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let currentUsername = "currentUsername"
        static let currentUserFullName = "currentUserFullName"
        static let currentUserEmail = "currentUserEmail"
        static let currentUserId = "currentUserId"
        static let isGuestMode = "isGuestMode"
    }
    
    var selectedCurrency: String {
        get {
            userDefaults.string(forKey: Keys.selectedCurrency) ?? "USD" //selectedCurrency yoksa → USD dön
        }
        set {
            userDefaults.set(newValue, forKey: Keys.selectedCurrency)
        }
    }
    
    var appCurrency: AppCurrency {
        AppCurrency(code: selectedCurrency)
    }
    
    var selectedLanguage: String {
        get {
            userDefaults.string(forKey: Keys.selectedLanguage) ?? "English" //selectedLanguage yoksa → English dön
        }
        set {
            userDefaults.set(newValue, forKey: Keys.selectedLanguage)
        }
    }
    
    var appLanguage: AppLanguage {
        get {
            AppLanguage(value: selectedLanguage)
        }
        set {
            selectedLanguage = newValue.rawValue
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
    
    var currentUsername: String? {
        get {
            userDefaults.string(forKey: Keys.currentUsername)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.currentUsername)
        }
    }

    var currentUserFullName: String? {
        get {
            userDefaults.string(forKey: Keys.currentUserFullName)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.currentUserFullName)
        }
    }

    var currentUserEmail: String? {
        get {
            userDefaults.string(forKey: Keys.currentUserEmail)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.currentUserEmail)
        }
    }
    
    var currentUserId: String? {
        get {
            userDefaults.string(forKey: Keys.currentUserId)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.currentUserId)
        }
    }

    var isGuestMode: Bool {
        get { userDefaults.bool(forKey: Keys.isGuestMode) }
        set { userDefaults.set(newValue, forKey: Keys.isGuestMode) }
    }

    /// Yerel portföy ve favori verilerini hesaplar arasında ayıran kimlik.
    /// Misafir verileri cihazda sabit bir alanda tutulur ve kayıtlı kullanıcı
    /// verileriyle hiçbir zaman aynı anahtarı paylaşmaz.
    var activeDataOwnerId: String? {
        if isGuestMode {
            return Self.guestDataOwnerId
        }

        guard let currentUserId, !currentUserId.isEmpty else {
            return nil
        }

        return currentUserId
    }

    func clearCurrentUserInfo() {
        userDefaults.removeObject(forKey: Keys.currentUserId)
        userDefaults.removeObject(forKey: Keys.currentUsername)
        userDefaults.removeObject(forKey: Keys.currentUserFullName)
        userDefaults.removeObject(forKey: Keys.currentUserEmail)
    }

    /// Hesap silindiğinde uygulamanın cihazda tuttuğu kullanıcı bilgilerini ve
    /// tercihleri varsayılan değerlerine döndürür.
    func clearAllLocalUserData() {
        clearCurrentUserInfo()
        userDefaults.removeObject(forKey: Keys.selectedLanguage)
        userDefaults.removeObject(forKey: Keys.selectedCurrency)
        userDefaults.removeObject(forKey: Keys.isBiometricEnabled)
        userDefaults.removeObject(forKey: Keys.hasSeenOnboarding)
        userDefaults.removeObject(forKey: Keys.isGuestMode)
    }
}
