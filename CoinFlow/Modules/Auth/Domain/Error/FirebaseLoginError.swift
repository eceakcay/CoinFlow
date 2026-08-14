//
//  FirebaseLoginError.swift
//  CoinFlow
//
//  Created by Ece Akcay on 14.08.2026.
//

import Foundation

enum FirebaseLoginError: Error {
    case invalidEmail
    case wrongPassword
    case userNotFound
    case userDisabled
    case networkError
    case tooManyRequests
    case invalidCredential
    case unknown
}
