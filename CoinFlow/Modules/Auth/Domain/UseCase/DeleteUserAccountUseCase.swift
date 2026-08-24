//
//  DeleteUserAccountUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 19.08.2026.
//

import Foundation

final class DeleteUserAccountUseCase {

    // MARK: - Dependencies

    private let deleteAccountUseCase: DeleteAccountUseCase
    private let deleteAllPortfolioTransactionsUseCase: DeleteAllPortfolioTransactionsUseCase
    private let deleteAllFavoritesUseCase: DeleteAllFavoritesUseCase
    private let userDefaultsManager: UserDefaultsManager

    // MARK: - Init

    init( deleteAccountUseCase: DeleteAccountUseCase,
          deleteAllPortfolioTransactionsUseCase: DeleteAllPortfolioTransactionsUseCase,
          deleteAllFavoritesUseCase: DeleteAllFavoritesUseCase,
          userDefaultsManager: UserDefaultsManager
    ) {

        self.deleteAccountUseCase = deleteAccountUseCase
        self.deleteAllPortfolioTransactionsUseCase = deleteAllPortfolioTransactionsUseCase
        self.deleteAllFavoritesUseCase = deleteAllFavoritesUseCase
        self.userDefaultsManager = userDefaultsManager
    }

    // MARK: - Execute

    func execute( password: String) async throws {

        // Önce Firebase hesabını siliyoruz.
        // Firebase silme başarısız olursa local verileri kaybetmiyoruz.
        try await deleteAccountUseCase.execute(password: password)

        // Firebase hesabı silindikten sonra
        // kullanıcıya ait portfolio verilerini temizle.
        try deleteAllPortfolioTransactionsUseCase.execute()

        // Kullanıcıya ait favorileri temizle.
        deleteAllFavoritesUseCase.execute()

        // En son kullanıcı bilgileriyle birlikte dil, para birimi, biyometri,
        // onboarding ve kullanım modu tercihlerini temizle.
        userDefaultsManager.clearAllLocalUserData()
    }
}
