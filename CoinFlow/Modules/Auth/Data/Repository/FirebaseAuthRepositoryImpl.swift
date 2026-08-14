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
            userDefaultsManager.clearCurrentUserInfo()
        } catch {
            throw AuthError.logoutFailed
        }
    }

    // MARK: - Private Methods
    
    private func saveUserInfo(from session: AuthSession) {
        userDefaultsManager.currentUserId = session.userId
        userDefaultsManager.currentUsername = session.username
        userDefaultsManager.currentUserFullName = session.fullName
        userDefaultsManager.currentUserEmail = session.email
    }
    
    // MARK: - Error Mapping

    private func mapRegistrationError(_ error: Error) -> RegistrationError {

        let nsError = error as NSError

        guard let errorCode = AuthErrorCode(rawValue: nsError.code) else {
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

        let nsError = error as NSError

        print("❌ Firebase Login error code:", nsError.code)
        print("❌ Firebase Login error:", nsError.localizedDescription)

        guard let errorCode = AuthErrorCode(rawValue: nsError.code) else {
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
