//
//  AuthRepositoryImpl.swift
//  CoinFlow
//
//  Created by Ece Akcay on 12.08.2026.
//

import Foundation

final class AuthRepositoryImpl: AuthRepositoryProtocol {

    private enum KeychainKeys {
        static let accessToken = "coinflow_access_token"
        static let refreshToken = "coinflow_refresh_token"
    }

    private let service: AuthAPIService
    private let keychainManager: KeychainManager
    private let userDefaultsManager: UserDefaultsManager

    init(
        service: AuthAPIService,
        keychainManager: KeychainManager = .shared,
        userDefaultsManager: UserDefaultsManager = .shared
    ) {
        self.service = service
        self.keychainManager = keychainManager
        self.userDefaultsManager = userDefaultsManager
    }

    func login(username: String, password: String) async throws -> AuthSession {
        do {
            let responseDTO = try await service.login(
                username: username,
                password: password
            )

            let session = AuthMapper.map(responseDTO)
            
            try keychainManager.save(
                session.accessToken,
                forKey: KeychainKeys.accessToken
            )

            try keychainManager.save(
                session.refreshToken,
                forKey: KeychainKeys.refreshToken
            )

            userDefaultsManager.currentUserId = session.userId
            userDefaultsManager.currentUsername = session.username
            userDefaultsManager.currentUserFullName = session.fullName
            userDefaultsManager.currentUserEmail = session.email

            return session

        } catch let keychainError as KeychainError {
            switch keychainError {
            case .saveFailed:
                throw AuthError.keychainSaveFailed
            default:
                throw AuthError.unknown
            }

        } catch let networkError as NetworkError {
            switch networkError {
            case .statusCode(let code):
                if code == 400 || code == 401 {
                    throw AuthError.invalidCredentials
                } else {
                    throw AuthError.loginFailed
                }

            case .noInternet:
                throw networkError

            default:
                throw AuthError.loginFailed
            }

        } catch {
            throw AuthError.unknown
        }
    }

    func isLoggedIn() -> Bool {
        let accessToken = keychainManager.read(
            forKey: KeychainKeys.accessToken
        )

        return accessToken != nil
    }

    func logout() throws {
        do {
            try keychainManager.delete(forKey: KeychainKeys.accessToken)
            try keychainManager.delete(forKey: KeychainKeys.refreshToken)
            
            userDefaultsManager.clearCurrentUserInfo()
        } catch {
            throw AuthError.logoutFailed
        }
    }
}
