//
//  BiometricAuthManager.swift
//  CoinFlow
//
//  Created by Ece Akcay on 30.06.2026.
//

import Foundation
import LocalAuthentication

enum BiometricAuthError: Error {
    case notAvailable
    case notEnrolled
    case cancelled
    case failed
}

final class BiometricAuthManager {

    static let shared = BiometricAuthManager()

    private init() {}

    func authenticate(reason: String) async throws -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"

        var error: NSError?

        guard context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        ) else {
            if let laError = error as? LAError {
                switch laError.code {
                case .biometryNotAvailable:
                    throw BiometricAuthError.notAvailable
                case .biometryNotEnrolled:
                    throw BiometricAuthError.notEnrolled
                default:
                    throw BiometricAuthError.failed
                }
            }

            throw BiometricAuthError.notAvailable
        }

        return try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            ) { success, error in
                if success {
                    continuation.resume(returning: true)
                    return
                }

                if let laError = error as? LAError {
                    switch laError.code {
                    case .userCancel, .systemCancel, .appCancel:
                        continuation.resume(throwing: BiometricAuthError.cancelled)
                    case .biometryNotAvailable:
                        continuation.resume(throwing: BiometricAuthError.notAvailable)
                    case .biometryNotEnrolled:
                        continuation.resume(throwing: BiometricAuthError.notEnrolled)
                    default:
                        continuation.resume(throwing: BiometricAuthError.failed)
                    }
                } else {
                    continuation.resume(throwing: BiometricAuthError.failed)
                }
            }
        }
    }
}
