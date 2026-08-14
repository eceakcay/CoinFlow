//
//  RegistrationError.swift
//  CoinFlow
//
//  Created by Ece Akcay on 14.08.2026.
//

import Foundation

enum RegistrationError: Error {
    case emailAlreadyInUse
    case invalidEmail
    case weakPassword
    case networkError
    case tooManyRequests
    case operationNotAllowed
    case unknown
}
