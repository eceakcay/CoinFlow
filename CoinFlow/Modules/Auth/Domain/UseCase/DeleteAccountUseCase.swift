//
//  DeleteAccountUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 19.08.2026.
//

import Foundation

final class DeleteAccountUseCase {

    // MARK: - Dependencies

    private let repository: FirebaseAuthRepositoryProtocol

    // MARK: - Init

    init(repository: FirebaseAuthRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execute

    func execute(password: String) async throws {
        try await repository.deleteAccount(password: password)
    }
}
