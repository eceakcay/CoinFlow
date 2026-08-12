//
//  AuthRepositoryProtocol.swift
//  CoinFlow
//
//  Created by Ece Akcay on 12.08.2026.
//

import Foundation

protocol AuthRepositoryProtocol {
    func login(username: String, password: String) async throws -> AuthSession
    func isLoggedIn() -> Bool
    func logout() throws
}
