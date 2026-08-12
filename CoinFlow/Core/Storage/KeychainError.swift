//
//  KeychainError.swift
//  CoinFlow
//
//  Created by Ece Akcay on 12.08.2026.
//

import Foundation

enum KeychainError: Error {
    case saveFailed
    case readFailed
    case deleteFailed
}
