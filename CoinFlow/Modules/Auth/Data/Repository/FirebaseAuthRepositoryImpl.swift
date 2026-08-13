//
//  FirebaseAuthRepositoryImpl.swift
//  CoinFlow
//
//  Created by Ece Akcay on 13.08.2026.
//

import Foundation

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
            throw AuthError.loginFailed
        }
    }

    func register(email: String, password: String) async throws -> AuthSession {
        do {
            let session = try await firebaseAuthService.register(
                email: email,
                password: password
            )

            saveUserInfo(from: session)

            return session
        } catch {
            throw AuthError.loginFailed
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
        userDefaultsManager.currentUsername = session.username
        userDefaultsManager.currentUserFullName = session.fullName
        userDefaultsManager.currentUserEmail = session.email
    }
}
