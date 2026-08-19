//
//  AuthError.swift
//  CoinFlow
//
//  Created by Ece Akcay on 12.08.2026.
//

import Foundation

enum AuthError: Error {

    case invalidCredentials
    case keychainSaveFailed
    case logoutFailed
    case loginFailed

    case userNotFound
    case invalidPassword
    case requiresRecentLogin
    case deleteAccountFailed

    case unknown
}

extension AuthError: LocalizedError {

    var errorDescription: String? {

        switch self {
        case .invalidCredentials:
            return "Username or password is incorrect."
        case .keychainSaveFailed:
            return "Login session could not be saved."
        case .logoutFailed:
            return "Logout failed."
        case .loginFailed:
            return "We couldn’t sign you in. Please try again."
        case .userNotFound:
            return "User not found."
        case .invalidPassword:
            return "The password is incorrect."
        case .requiresRecentLogin:
            return "For security reasons, please sign in again."
        case .deleteAccountFailed:
            return "Your account could not be deleted. Please try again."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
