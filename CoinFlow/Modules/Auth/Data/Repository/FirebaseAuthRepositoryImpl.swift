//
//  FirebaseAuthRepositoryImpl.swift
//  CoinFlow
//
//  Created by Ece Akcay on 13.08.2026.
//

import Foundation
import FirebaseAuth

final class FirebaseAuthRepositoryImpl: FirebaseAuthRepositoryProtocol {

    // MARK: - Dependencies

    private let firebaseAuthService: FirebaseAuthService
    private let userDefaultsManager: UserDefaultsManager

    // MARK: - Init

    init(
        firebaseAuthService: FirebaseAuthService,
        userDefaultsManager: UserDefaultsManager = .shared
    ) {
        self.firebaseAuthService = firebaseAuthService
        self.userDefaultsManager = userDefaultsManager
    }

    // MARK: - FirebaseAuthRepositoryProtocol

    func login(email: String, password: String) async throws -> AuthSession {
        do {
            let session = try await firebaseAuthService.login(
                email: email,
                password: password
            )

            // Önceki hesap veya misafir oturumuna ait portföy bilgisinin
            // yeni kullanıcıya kısa süreliğine gösterilmesini engelle.
            PortfolioWidgetSnapshotStore.clear()
            saveUserInfo(from: session)

            return session

        } catch {
            throw mapLoginError(error)
        }
    }

    func register(firstName: String,lastName: String,email: String,password: String) async throws -> AuthSession {
        do {
            let session = try await firebaseAuthService.register(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password
            )

            PortfolioWidgetSnapshotStore.clear()
            saveUserInfo(from: session)

            return session

        } catch {
            throw mapRegistrationError(error)
        }
    }

    func isLoggedIn() -> Bool {
        firebaseAuthService.isLoggedIn()
    }

    func logout() throws {
        do {
            try firebaseAuthService.logout()
            PortfolioWidgetSnapshotStore.clear()
            userDefaultsManager.clearCurrentUserInfo()

        } catch {
            throw AuthError.logoutFailed
        }
    }

    func deleteAccount(password: String) async throws {
        do {
            try await firebaseAuthService.deleteAccount(password: password)

        } catch {
            guard let errorCode = firebaseErrorCode(from: error) else {
                throw AuthError.deleteAccountFailed
            }

            switch errorCode {

            case .wrongPassword, .invalidCredential:
                throw AuthError.invalidPassword

            case .requiresRecentLogin:
                throw AuthError.requiresRecentLogin

            case .userNotFound:
                throw AuthError.userNotFound

            default:
                throw AuthError.deleteAccountFailed
            }
        }
    }

    func sendPasswordReset(email: String) async throws {
        try await firebaseAuthService
            .sendPasswordReset(
                email: email
            )
    }

    // MARK: - Private Methods

    private func saveUserInfo(from session: AuthSession) {
        userDefaultsManager.currentUserId = session.userId
        userDefaultsManager.currentUsername = session.username
        userDefaultsManager.currentUserFullName = session.fullName
        userDefaultsManager.currentUserEmail = session.email
    }

    private func firebaseErrorCode(from error: Error) -> AuthErrorCode? {
        let nsError = error as NSError

        return AuthErrorCode(rawValue: nsError.code)
    }

    // MARK: - Error Mapping

    private func mapRegistrationError(_ error: Error) -> RegistrationError {
        guard let errorCode = firebaseErrorCode(from: error) else {
            return .unknown
        }

        switch errorCode {

        case .emailAlreadyInUse:
            return .emailAlreadyInUse

        case .invalidEmail:
            return .invalidEmail

        case .weakPassword:
            return .weakPassword

        case .networkError:
            return .networkError

        case .tooManyRequests:
            return .tooManyRequests

        case .operationNotAllowed:
            return .operationNotAllowed

        default:
            return .unknown
        }
    }

    private func mapLoginError(_ error: Error) -> FirebaseLoginError {
        guard let errorCode = firebaseErrorCode(from: error) else {
            return .unknown
        }

        switch errorCode {

        case .invalidEmail:
            return .invalidEmail

        case .wrongPassword:
            return .wrongPassword

        case .userNotFound:
            return .userNotFound

        case .userDisabled:
            return .userDisabled

        case .networkError:
            return .networkError

        case .tooManyRequests:
            return .tooManyRequests

        case .invalidCredential:
            return .invalidCredential

        default:
            return .unknown
        }
    }
}
