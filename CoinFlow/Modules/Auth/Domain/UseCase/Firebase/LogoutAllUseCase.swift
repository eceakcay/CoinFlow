//
//  LogoutAllUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 13.08.2026.
//

import Foundation

final class LogoutAllUseCase {

    private let logoutUseCase: LogoutUseCase
    private let firebaseLogoutUseCase: FirebaseLogoutUseCase

    init(
        logoutUseCase: LogoutUseCase,
        firebaseLogoutUseCase: FirebaseLogoutUseCase
    ) {
        self.logoutUseCase = logoutUseCase
        self.firebaseLogoutUseCase = firebaseLogoutUseCase
    }

    func execute() {
        try? logoutUseCase.execute()
        try? firebaseLogoutUseCase.execute()
    }
}
