//
//  CheckFirebaseAuthStatusUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 13.08.2026.
//

import Foundation

final class CheckFirebaseAuthStatusUseCase {

    private let repository: FirebaseAuthRepositoryProtocol

    init(repository: FirebaseAuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> Bool {
        repository.isLoggedIn()
    }
}
