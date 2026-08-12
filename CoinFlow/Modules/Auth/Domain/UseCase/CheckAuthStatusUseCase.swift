//
//  CheckAuthStatusUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 12.08.2026.
//

import Foundation

final class CheckAuthStatusUseCase {

    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> Bool {
        repository.isLoggedIn()
    }
}
