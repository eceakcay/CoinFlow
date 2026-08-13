//
//  FirebaseLogoutUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 13.08.2026.
//

import Foundation

final class FirebaseLogoutUseCase {

    private let repository: FirebaseAuthRepositoryProtocol

    init(repository: FirebaseAuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute() throws {
        try repository.logout()
    }
}
