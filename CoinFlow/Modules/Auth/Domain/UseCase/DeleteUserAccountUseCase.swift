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
    private let userDefaultsManager: UserDefaultsManager

    // MARK: - Init

    init(
        deleteAccountUseCase: DeleteAccountUseCase,
        deleteAllPortfolioTransactionsUseCase:DeleteAllPortfolioTransactionsUseCase,
        userDefaultsManager:UserDefaultsManager
    ) {

        self.deleteAccountUseCase = deleteAccountUseCase
        self.deleteAllPortfolioTransactionsUseCase = deleteAllPortfolioTransactionsUseCase
        self.userDefaultsManager = userDefaultsManager
    }

    // MARK: - Execute

    func execute(password: String) async throws {

        // Önce Firebase hesabını sil.
        try await deleteAccountUseCase.execute(password: password)

        // Firebase silme başarılı olduktan sonra
        // kullanıcının local portfolio verilerini temizle.
        try deleteAllPortfolioTransactionsUseCase.execute()

        // Kullanıcıya ait local bilgileri temizle.
        userDefaultsManager.clearCurrentUserInfo()
    }
}
