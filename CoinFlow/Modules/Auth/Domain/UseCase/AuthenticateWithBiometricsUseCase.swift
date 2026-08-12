//
//  AuthenticateWithBiometricsUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 12.08.2026.
//

import Foundation

final class AuthenticateWithBiometricsUseCase {

    private let biometricAuthManager: BiometricAuthManager

    init(biometricAuthManager: BiometricAuthManager = .shared) {
        self.biometricAuthManager = biometricAuthManager
    }

    func execute(reason: String) async throws -> Bool {
        try await biometricAuthManager.authenticate(reason: reason)
    }
}
