//
//  LoginUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 12.08.2026.
//

import Foundation

final class LoginUseCase {

    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(username: String, password: String) async throws -> AuthSession {
        try await repository.login(
            username: username,
            password: password
        )
    }
}
