//
//  FirebaseAuthService.swift
//  CoinFlow
//
//  Created by Ece Akcay on 13.08.2026.
//

import Foundation
import FirebaseAuth

final class FirebaseAuthService {
    
    func login(email: String, password: String) async throws -> AuthSession {
        print("Firebase LOGIN çalıştı:", email)

        let result = try await Auth.auth().signIn(withEmail: email,password: password)

        return try await makeSession(from: result.user)
    }

    func register(firstName: String, lastName: String, email: String, password: String) async throws -> AuthSession {
        print("Firebase REGISTER çalıştı:", email)

        let result = try await Auth.auth().createUser(withEmail: email,password: password)
        let fullName = "\(firstName) \(lastName)"


        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = fullName

        try await changeRequest.commitChanges()

        return try await makeSession(from: result.user)
    }
    
    func isLoggedIn() -> Bool {
        Auth.auth().currentUser != nil
    }
    
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    private func makeSession(from user: User) async throws -> AuthSession {
        
        let token = try await user.getIDToken()
        
        let email = user.email ?? ""
        let displayName = user.displayName ?? email
        
        return AuthSession(
            userId: user.uid,
            username: email,
            email: email,
            fullName: displayName.isEmpty ? "CoinFlow User" : displayName,
            accessToken: token,
            refreshToken: token
        )
    }
}
