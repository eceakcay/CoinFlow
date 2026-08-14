//
//  LogoutAllUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 14.08.2026.
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

    func execute() throws {

        var firstError: Error?

        // DummyJSON oturumunu kapatmayı dene
        do {
            try logoutUseCase.execute()
        } catch {
            firstError = error
        }

        // DummyJSON hata verse bile Firebase logout'u dene
        do {
            try firebaseLogoutUseCase.execute()
        } catch {
            if firstError == nil {
                firstError = error
            }
        }

        // Herhangi bir logout başarısız olduysa yukarı bildir
        if let firstError {
            throw firstError
        }
    }
}
