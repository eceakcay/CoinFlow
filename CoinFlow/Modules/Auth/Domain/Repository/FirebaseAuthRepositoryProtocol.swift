//
//  FirebaseAuthRepositoryProtocol.swift
//  CoinFlow
//
//  Created by Ece Akcay on 13.08.2026.
//

import Foundation

protocol FirebaseAuthRepositoryProtocol {
    func login(email: String, password: String) async throws -> AuthSession
    func register(firstName: String, lastName: String, email: String, password: String) async throws -> AuthSession
    func isLoggedIn() -> Bool
    func logout() throws
}
