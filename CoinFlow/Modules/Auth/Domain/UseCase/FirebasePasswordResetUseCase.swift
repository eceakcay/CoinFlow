//
//  FirebasePasswordResetUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 18.08.2026.
//

import Foundation

final class FirebasePasswordResetUseCase {

    private let repository: FirebaseAuthRepositoryProtocol

    init(repository:FirebaseAuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(email: String) async throws {
        try await repository.sendPasswordReset(email: email)
    }
}
