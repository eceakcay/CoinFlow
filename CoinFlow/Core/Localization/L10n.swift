//
//  L10n.swift
//  CoinFlow
//
//  Created by Ece Akcay on 11.08.2026.
//

import Foundation

enum L10nKey {
    case profile
    case appSubtitle

    case preferences
    case currency
    case language

    case security
    case biometricLogin
    case biometricSubtitle
    
    case dashboard
    case portfolio
    case market
    case favorites

    case searchCoinsPlaceholder
    case noCoinsFound
    case trySearchingAnotherCoin
    case unableToLoadMarket

    case noFavoriteCoinsYet
    case favoriteEmptyMessage
    
    case priceChart
    case marketCap
    case volume
    case rank
    case change
    case chartDataNotAvailable
    
    case totalBalance
    case investedCapital
    case profitLoss
    case buy
    case sell
    case totalPaid
    case noPortfolioTransactionsYet
    
    case addTransaction
    case trackYourCrypto
    case trackYourCryptoSubtitle
    case selectCoin
    case chooseFromMarketList
    case amountPlaceholder
    case pricePerCoinPlaceholder
    case saveBuyTransaction
    case saveSellTransaction
    case warning
    case pleaseSelectCoin
    case validAmount
    case validPrice
    
    case searchForCoin
    case notAvailable
    
    case unableToLoadFavorites
    case remove
    
    case goodMorning
    case goodAfternoon
    case goodEvening

    case totalPortfolioValue
    case totalPL
    case addHolding
    case exploreMarket
    case topHoldings
    case topTransactions
    case seeAll
    case total
    
    case unableToLoadDashboard
    case checkConnectionAndTryAgain
    case noHoldingsYet
    case noHoldingsMessage
    case noTransactionsYet
    case latestTransactionsMessage
    
    case app
    case appInfo
    case appInfoSubtitle
    case appInfoMessage

    case dangerZone
    case resetPortfolioData
    case resetPortfolioSubtitle
    case resetPortfolioTitle
    case resetPortfolioMessage

    case done
    case ok
    case connectionError
    case cancel
    case reset
    case portfolioReset
    case portfolioResetMessage
    case resetFailed

    case currencySelectionDescription
    case languageSelectionDescription
    
    case logout
    case logoutSubtitle
    case logoutTitle
    case logoutMessage
    case logoutFailed
    
    case loginSubtitle
    case username
    case password
    case forgotPassword
    case signIn
    case or
    case signInWithFaceID
    case emailRequired
    case passwordResetTitle
    case passwordResetSent
    case passwordResetFailed
    case passwordRequired
    case passwordResetNotAvailable
    case signInBeforeFaceID
    case invalidCredentials
    case loginAccountNotFound
    case loginFailedMessage
    
    case faceIDReason
    case faceIDNotAvailable
    case faceIDNotEnrolled
    case faceIDFailed
    case biometricNotEnabled
    
    case insufficientHoldingAmount
    case buyRequiredByLaterSale
    
    case createAccount
    case accountCreated
    case accountCreatedMessage
    case signInWithFirebase
    case validEmail
    case firebaseLoginFailed
    case firebaseRegisterFailed
    case email
    case firstNameRequired
    case lastNameRequired
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case tooManyRequests
    case registrationNotAllowed
    case userDisabled
    
    case firebaseLoginTitle
    case firebaseLoginSubtitle
    case firstName
    case lastName
    case createAccountSubtitle
    case firstNamePlaceholder
    case lastNamePlaceholder
    case emailPlaceholder
    
    case currentPrice
    case deleteAccountFailed
    case accountDeletionRequiresInternet
    case invalidPassword
    case requiresRecentLogin
    case userNotFound
    case deleteAccount
    case deleteAccountSubtitle
    case deleteAccountConfirmationMessage
    case passwordPlaceholder
    case deletingAccount
    case continueAsGuest
    case guestUser
    case account
    case signInSubtitle
    case privacyPolicy
    case privacyPolicySubtitle
    case onboardingSkip
    case onboardingNext
    case onboardingGetStarted
    case onboardingMarketTitle
    case onboardingMarketMessage
    case onboardingPortfolioTitle
    case onboardingPortfolioMessage
    case onboardingGuestTitle
    case onboardingGuestMessage
    
}

enum L10n {

    static func text(_ key: L10nKey,language: AppLanguage = UserDefaultsManager.shared.appLanguage) -> String {
        switch language {
        case .english:
            return english[key] ?? ""
        case .turkish:
            return turkish[key] ?? ""
        }
    }

    private static let english: [L10nKey: String] = [
        .profile: "Profile",
        .appSubtitle: "Crypto Portfolio Tracker",

        .preferences: "Preferences",
        .currency: "Currency",
        .language: "Language",

        .security: "Security",
        .biometricLogin: "Biometric Login",
        .biometricSubtitle: "Face ID",
        
        .dashboard: "Dashboard",
        .portfolio: "Portfolio",
        .market: "Market",
        .favorites: "Favorites",
        
        .searchCoinsPlaceholder: "Search coins...",
        .noCoinsFound: "No coins found",
        .trySearchingAnotherCoin: "Try searching for another coin.",
        .unableToLoadMarket: "Unable to Load Market",
        
        .noFavoriteCoinsYet: "No favorite coins yet",
        .favoriteEmptyMessage: "Tap the heart icon on a coin detail page to add it here.",
        
        .priceChart: "Price Chart",
        .marketCap: "Market Cap",
        .volume: "Volume",
        .rank: "Rank",
        .change: "Change",
        .chartDataNotAvailable: "Chart data not available",
        
        .totalBalance: "Total Balance",
        .investedCapital: "Invested Capital",
        .profitLoss: "Profit / Loss",
        .buy: "BUY",
        .sell: "SELL",
        .totalPaid: "Total paid",
        .noPortfolioTransactionsYet: "No portfolio transactions yet.",
        
        .addTransaction: "Add Transaction",
        .trackYourCrypto: "Track Your Crypto",
        .trackYourCryptoSubtitle: "Select a coin and add your buy or sell transaction.",
        .selectCoin: "Select Coin",
        .chooseFromMarketList: "Choose from market list",
        .amountPlaceholder: "Amount, e.g. 0.02",
        .pricePerCoinPlaceholder: "Price per coin, e.g. 65000",
        .saveBuyTransaction: "Save Buy Transaction",
        .saveSellTransaction: "Save Sell Transaction",
        .warning: "Warning",
        .pleaseSelectCoin: "Please select a coin.",
        .validAmount: "Please enter a valid amount.",
        .validPrice: "Please enter a valid price.",
        
        .searchForCoin: "Search for a coin",
        .notAvailable: "N/A",
        
        .unableToLoadFavorites: "Unable to Load Favorites",
        .remove: "Remove",
        
        .goodMorning: "Good morning,",
        .goodAfternoon: "Good afternoon,",
        .goodEvening: "Good evening,",
        
        .totalPortfolioValue: "Total Portfolio Value",
        .totalPL: "Total P/L",
        .addHolding: "Add Holding",
        .exploreMarket: "Explore Market",
        .topHoldings: "Top Holdings",
        .topTransactions: "Top Transactions",
        .seeAll: "See All",
        .total: "Total:",
        
        .unableToLoadDashboard: "Unable to Load Dashboard",
        .checkConnectionAndTryAgain: "Please check your connection and try again.",
        .noHoldingsYet: "No holdings yet",
        .noHoldingsMessage: "Add your first transaction to track your portfolio.",
        .noTransactionsYet: "No transactions yet",
        .latestTransactionsMessage: "Your latest transactions will appear here.",

        .app: "App",
        .appInfo: "App Info",
        .appInfoSubtitle: "CoinFlow v1.0",
        .appInfoMessage: """
        Crypto Portfolio Tracker
        Version 1.0

        CoinFlow does not provide financial or investment advice. Prices and market data are provided for informational purposes only and may not be real-time. Always do your own research before making investment decisions.
        """,
        .dangerZone: "Danger Zone",
        .resetPortfolioData: "Reset Portfolio Data",
        .resetPortfolioSubtitle: "Delete all saved transactions",
        .resetPortfolioTitle: "Reset Portfolio Data?",
        .resetPortfolioMessage: "This action will delete all saved transactions. This cannot be undone.",

        .done: "Done",
        .ok: "OK",
        .connectionError: "Connection Error",
        .cancel: "Cancel",
        .reset: "Reset",
        .portfolioReset: "Portfolio Reset",
        .portfolioResetMessage: "All saved transactions have been deleted.",
        .resetFailed: "Reset Failed",

        .currencySelectionDescription: "Choose the currency used across the app.",
        .languageSelectionDescription: "Choose your preferred app language.",
        
        .logout: "Logout",
        .logoutSubtitle: "Sign out from your account",
        .logoutTitle: "Logout?",
        .logoutMessage: "You will need to login again to access your portfolio.",
        .logoutFailed: "Logout Failed",
        
        .loginSubtitle: "Your portfolio, your control.",
        .username: "Username",
        .password: "Password",
        .forgotPassword: "Forgot Password?",
        .signIn: "Sign In",
        .or: "or",
        .signInWithFaceID: "Sign in with Face ID",
        .emailRequired: "Please enter your email",
        .passwordResetTitle: "Email Sent",
        .passwordResetSent: "A password reset link has been sent to your email address.",
        .passwordResetFailed: "The password reset email could not be sent.",
        .passwordRequired: "Please enter your password.",
        .passwordResetNotAvailable: "Password reset is not available for demo accounts.",
        .signInBeforeFaceID: "Please sign in once before using Face ID.",
        .invalidCredentials: "Email or password is incorrect. If you don't have an account, tap Create Account.",
        .loginAccountNotFound: "No account was found for this email. Tap Create Account to register.",
        .loginFailedMessage: "We couldn’t sign you in. Please try again.",
        
        .faceIDReason: "Unlock your CoinFlow portfolio.",
        .faceIDNotAvailable: "Face ID is not available on this device.",
        .faceIDNotEnrolled: "Face ID is not set up on this device.",
        .faceIDFailed: "Face ID authentication failed. Please try again.",
        .biometricNotEnabled: "Biometric login is not enabled.",
        
        .insufficientHoldingAmount: "You cannot sell more than your current holding.",
        .buyRequiredByLaterSale: "This buy cannot be deleted because a later sale depends on it.",
        
        .createAccount: "Create Account",
        .accountCreated: "Account Created",
        .accountCreatedMessage: "Your account has been created successfully.",
        .signInWithFirebase: "Sign in",
        .validEmail: "Please enter a valid email address.",
        .firebaseLoginFailed: "Account not found or password is incorrect.",
        .firebaseRegisterFailed: "Account could not be created.",
        .email: "Email",
        .firstNameRequired: "First name is required.",
        .lastNameRequired: "Last name is required.",
        .emailAlreadyInUse: "An account already exists with this email.",
        .weakPassword: "Password is too weak. Please choose a stronger password.",
        .networkError: "Please check your internet connection and try again.",
        .tooManyRequests: "Too many attempts. Please try again later.",
        .registrationNotAllowed: "Account registration is currently unavailable.",
        .userDisabled: "This user account has been disabled.",
        
        .firebaseLoginTitle: "Login",
        .firebaseLoginSubtitle: "Sign in to your CoinFlow account.",
        .createAccountSubtitle: "Create your CoinFlow account.",
        .firstName: "First Name",
        .firstNamePlaceholder: "Enter your first name",
        .lastName: "Last Name",
        .lastNamePlaceholder:"Enter your last name",
        .emailPlaceholder: "Enter your email address",
        
        .currentPrice: "Current",
        .deleteAccountFailed: "Your account could not be deleted. Please try again.",
        .accountDeletionRequiresInternet: "Connect to the internet to delete your account.",
        .invalidPassword: "Your password is incorrect.",
        .requiresRecentLogin: "For security reasons, please sign in again.",
        .userNotFound: "User not found.",
        .deleteAccount: "Delete Account",
        .deleteAccountSubtitle: "Permanently delete your account and data.",
        .deleteAccountConfirmationMessage: "This action cannot be undone. Enter your password to permanently delete your account.",
        .passwordPlaceholder: "Enter your password",
        .deletingAccount: "Deleting your account...",
        .continueAsGuest: "Continue as Guest",
        .guestUser: "Guest User",
        .account: "Account",
        .signInSubtitle: "Sign in to sync and secure your account",
        .privacyPolicy: "Privacy Policy",
        .privacyPolicySubtitle: "Learn how your data is handled",
        .onboardingSkip: "Skip",
        .onboardingNext: "Next",
        .onboardingGetStarted: "Get Started",
        .onboardingMarketTitle: "Follow the Market",
        .onboardingMarketMessage: "Explore live cryptocurrency prices, search for coins, and review historical charts.",
        .onboardingPortfolioTitle: "Track Your Portfolio",
        .onboardingPortfolioMessage: "Record buy and sell transactions and monitor your balance, invested capital, and profit or loss.",
        .onboardingGuestTitle: "Start Your Way",
        .onboardingGuestMessage: "Use CoinFlow without an account or sign in to secure your account. Your guest data stays on this device."
        
    ]

    private static let turkish: [L10nKey: String] = [
        .profile: "Profil",
        .appSubtitle: "Kripto Portföy Takipçisi",

        .preferences: "Tercihler",
        .currency: "Para Birimi",
        .language: "Dil",

        .security: "Güvenlik",
        .biometricLogin: "Biyometrik Giriş",
        .biometricSubtitle: "Face ID",
        
        .dashboard: "Anasayfa",
        .portfolio: "Portföy",
        .market: "Market",
        .favorites: "Favoriler",
    
        .searchCoinsPlaceholder: "Coin ara...",
        .noCoinsFound: "Coin bulunamadı",
        .trySearchingAnotherCoin: "Başka bir coin aramayı dene.",
        .unableToLoadMarket: "Market yüklenemedi",

        .noFavoriteCoinsYet: "Henüz favori coin yok",
        .favoriteEmptyMessage: "Favorilere eklemek için coin detay sayfasındaki kalp ikonuna dokun.",
        
        .priceChart: "Fiyat Grafiği",
        .marketCap: "Piyasa Değeri",
        .volume: "Hacim",
        .rank: "Sıralama",
        .change: "Değişim",
        .chartDataNotAvailable: "Grafik verisi bulunamadı",
        
        .totalBalance: "Toplam Bakiye",
        .investedCapital: "Yatırılan Sermaye",
        .profitLoss: "Kar / Zarar",
        .buy: "ALIŞ",
        .sell: "SATIŞ",
        .totalPaid: "Toplam",
        .noPortfolioTransactionsYet: "Henüz portföy işlemi yok.",
        
        .addTransaction: "İşlem Ekle",
        .trackYourCrypto: "Kriptonu Takip Et",
        .trackYourCryptoSubtitle: "Bir coin seç ve alış ya da satış işlemini ekle.",
        .selectCoin: "Coin Seç",
        .chooseFromMarketList: "Market listesinden seç",
        .amountPlaceholder: "Miktar, örn. 0.02",
        .pricePerCoinPlaceholder: "Coin başı fiyat, örn. 65000",
        .saveBuyTransaction: "Alış İşlemini Kaydet",
        .saveSellTransaction: "Satış İşlemini Kaydet",
        .warning: "Uyarı",
        .pleaseSelectCoin: "Lütfen bir coin seç.",
        .validAmount: "Lütfen geçerli bir miktar gir.",
        .validPrice: "Lütfen geçerli bir fiyat gir.",
        
        .searchForCoin: "Coin ara",
        .notAvailable: "Yok",
        
        .unableToLoadFavorites: "Favoriler yüklenemedi",
        .remove: "Kaldır",
        
        .goodMorning: "Günaydın,",
        .goodAfternoon: "İyi günler,",
        .goodEvening: "İyi akşamlar,",

        .totalPortfolioValue: "Toplam Portföy Değeri",
        .totalPL: "Toplam Kar/Zarar",
        .addHolding: "Varlık Ekle",
        .exploreMarket: "Marketi Keşfet",
        .topHoldings: "Portföyde Öne Çıkanlar",
        .topTransactions: "Son İşlemler",
        .seeAll: "Tümünü Gör",
        .total: "Toplam:",
        
        .unableToLoadDashboard: "Anasayfa yüklenemedi",
        .checkConnectionAndTryAgain: "Bağlantını kontrol edip tekrar dene.",
        .noHoldingsYet: "Henüz varlık yok",
        .noHoldingsMessage: "Portföyünü takip etmek için ilk işlemini ekle.",
        .noTransactionsYet: "Henüz işlem yok",
        .latestTransactionsMessage: "Son işlemlerin burada görünecek.",

        .app: "Uygulama",
        .appInfo: "Uygulama Bilgisi",
        .appInfoSubtitle: "CoinFlow v1.0",
        .appInfoMessage: """
        Kripto Portföy Takipçisi
        Versiyon 1.0

        CoinFlow finansal veya yatırım tavsiyesi vermez. Gösterilen fiyatlar ve piyasa verileri yalnızca bilgilendirme amaçlıdır ve gerçek zamanlı olmayabilir. Yatırım kararı vermeden önce kendi araştırmanızı yapınız.
        """,
        .dangerZone: "Tehlikeli Alan",
        .resetPortfolioData: "Portföy Verilerini Sıfırla",
        .resetPortfolioSubtitle: "Kayıtlı tüm işlemleri sil",
        .resetPortfolioTitle: "Portföy verileri sıfırlansın mı?",
        .resetPortfolioMessage: "Bu işlem kayıtlı tüm işlemleri siler. Bu işlem geri alınamaz.",

        .done: "Bitir",
        .ok: "Tamam",
        .connectionError: "Bağlantı Hatası",
        .cancel: "Vazgeç",
        .reset: "Sıfırla",
        .portfolioReset: "Portföy Sıfırlandı",
        .portfolioResetMessage: "Kayıtlı tüm işlemler silindi.",
        .resetFailed: "Sıfırlama Başarısız",

        .currencySelectionDescription: "Uygulama genelinde kullanılacak para birimini seç.",
        .languageSelectionDescription: "Uygulama dilini seç.",
        
        .logout: "Çıkış Yap",
        .logoutSubtitle: "Hesabından çıkış yap",
        .logoutTitle: "Çıkış yapılsın mı?",
        .logoutMessage: "Portföyüne erişmek için tekrar giriş yapman gerekecek.",
        .logoutFailed: "Çıkış Başarısız",
        
        .loginSubtitle: "Portföyün senin kontrolünde.",
        .username: "Kullanıcı Adı",
        .password: "Şifre",
        .forgotPassword: "Şifremi Unuttum",
        .signIn: "Giriş Yap",
        .or: "veya",
        .signInWithFaceID: "Face ID ile giriş yap",
        .emailRequired: "Lütfen mail adresini gir.",
        .passwordResetTitle: "E-posta Gönderildi",
        .passwordResetSent: "Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.",
        .passwordResetFailed: "Şifre sıfırlama e-postası gönderilemedi.",
        .passwordRequired: "Lütfen şifreni gir.",
        .passwordResetNotAvailable: "Demo hesaplarda şifre sıfırlama kullanılamaz.",
        .signInBeforeFaceID: "Face ID kullanmadan önce bir kez giriş yapmalısın.",
        .invalidCredentials: "E-posta veya şifre hatalı. Bir hesabınız yoksa Hesap Oluştur'a dokunun.",
        .loginAccountNotFound: "Bu e-posta adresiyle kayıtlı bir hesap bulunamadı. Kaydolmak için Hesap Oluştur'a dokunun.",
        .loginFailedMessage: "Giriş yapılamadı. Lütfen tekrar dene.",
        
        .faceIDReason: "CoinFlow portföyünü aç.",
        .faceIDNotAvailable: "Bu cihazda Face ID kullanılamıyor.",
        .faceIDNotEnrolled: "Bu cihazda Face ID ayarlanmamış.",
        .faceIDFailed: "Face ID doğrulaması başarısız oldu. Lütfen tekrar dene.",
        .biometricNotEnabled: "Biyometrik giriş açık değil.",
        
        .insufficientHoldingAmount: "Elindeki miktardan fazla satış yapamazsın.",
        .buyRequiredByLaterSale: "Daha sonraki bir satış bu alışa bağlı olduğu için alış işlemi silinemez.",
        
        .createAccount: "Hesap Oluştur",
        .accountCreated: "Hesap Oluşturuldu",
        .accountCreatedMessage: "Hesabın başarıyla oluşturuldu.",
        .signInWithFirebase: "Giriş yap",
        .validEmail: "Lütfen geçerli bir e-posta adresi gir.",
        
        .firebaseLoginFailed: "Hesap bulunamadı veya şifre yanlış.",
        .firebaseRegisterFailed: "Hesap oluşturulamadı.",
        .email: "E-posta",
        .firstNameRequired: "Ad alanı zorunludur.",
        .lastNameRequired: "Soyad alanı zorunludur.",
        .emailAlreadyInUse:"Bu e-posta adresiyle zaten bir hesap oluşturulmuş.",
        .weakPassword: "Şifre çok zayıf. Lütfen daha güçlü bir şifre seç.",
        .networkError: "İnternet bağlantını kontrol edip tekrar dene.",
        .tooManyRequests: "Çok fazla deneme yapıldı. Lütfen daha sonra tekrar dene.",
        .registrationNotAllowed:"Şu anda hesap oluşturulamıyor.",
        .userDisabled: "Bu kullanıcı hesabı devre dışı bırakılmış.",
        
        .firebaseLoginTitle: "Giriş Yap",
        .firebaseLoginSubtitle: "CoinFlow hesabınıza giriş yapın.",
        .createAccountSubtitle:"CoinFlow hesabınızı oluşturun.",
        .firstName: "Ad",
        .firstNamePlaceholder: "Adınızı girin",
        .lastName: "Soyad",
        .lastNamePlaceholder: "Soyadınızı girin",
        .emailPlaceholder: "E-posta adresinizi girin",
        
        .currentPrice: "Güncel",
        .deleteAccountFailed: "Hesap silinemedi. Lütfen tekrar deneyin.",
        .accountDeletionRequiresInternet: "Hesabını silmek için internete bağlan.",
        .invalidPassword: "Şifreniz yanlış.",
        .requiresRecentLogin:"Güvenlik nedeniyle tekrar giriş yapmanız gerekiyor.",
        .userNotFound:"Kullanıcı bulunamadı.",
        .deleteAccount: "Hesabı Sil",
        .deleteAccountSubtitle: "Hesabınızı ve verilerinizi kalıcı olarak silin.",
        .deleteAccountConfirmationMessage: "Bu işlem geri alınamaz. Hesabınızı kalıcı olarak silmek için şifrenizi girin.",
        .passwordPlaceholder: "Şifrenizi girin",
        .deletingAccount: "Hesabınız siliniyor...",
        .continueAsGuest: "Misafir Olarak Devam Et",
        .guestUser: "Misafir Kullanıcı",
        .account: "Hesap",
        .signInSubtitle: "Hesabınızı güvenceye almak için giriş yapın",
        .privacyPolicy: "Gizlilik Politikası",
        .privacyPolicySubtitle: "Verilerinizin nasıl işlendiğini öğrenin",
        .onboardingSkip: "Atla",
        .onboardingNext: "İleri",
        .onboardingGetStarted: "Başla",
        .onboardingMarketTitle: "Piyasayı Takip Et",
        .onboardingMarketMessage: "Güncel kripto para fiyatlarını keşfet, coin ara ve geçmiş fiyat grafiklerini incele.",
        .onboardingPortfolioTitle: "Portföyünü İzle",
        .onboardingPortfolioMessage: "Alış ve satış işlemlerini kaydet; bakiyeni, yatırılan tutarı ve kâr veya zararını takip et.",
        .onboardingGuestTitle: "İstediğin Gibi Başla",
        .onboardingGuestMessage: "CoinFlow'u hesap oluşturmadan kullan veya hesabını güvenceye almak için giriş yap. Misafir verilerin bu cihazda kalır."
    ]
}
