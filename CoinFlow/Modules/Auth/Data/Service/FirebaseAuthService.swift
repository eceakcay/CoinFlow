//
//  FirebaseAuthService.swift
//  CoinFlow
//
//  Created by Ece Akcay on 13.08.2026.
//

import Foundation
import FirebaseAuth

final class FirebaseAuthService {
    
    // MARK: - Dependencies

        private let userDefaultsManager: UserDefaultsManager

        // MARK: - Init

        init(userDefaultsManager: UserDefaultsManager) {
            self.userDefaultsManager = userDefaultsManager
        }
    
    func login(email: String, password: String) async throws -> AuthSession {
        print("Firebase LOGIN çalıştı:", email)

        let result = try await Auth.auth().signIn(withEmail: email,password: password)

        return try await makeSession(from: result.user)
    }

    func register(firstName: String, lastName: String,email: String,password: String) async throws -> AuthSession {

        print("Firebase REGISTER başladı:", email)

        do {
            let result = try await Auth.auth().createUser(
                withEmail: email,
                password: password
            )

            print("Firebase user oluşturuldu")

            let fullName = "\(firstName) \(lastName)"

            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = fullName

            try await changeRequest.commitChanges()


            let session = try await makeSession(
                from: result.user
            )

            print("Firebase REGISTER tamamlandı")

            return session

        } catch {
            let nsError = error as NSError

            print("FIREBASE REGISTER FAILED")
            print("Code:", nsError.code)
            print("Message:", nsError.localizedDescription)
            print("UserInfo:", nsError.userInfo)

            throw error
        }
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
    
    func deleteAccount(password: String) async throws {

        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            throw AuthError.userNotFound
        }

        let credential = EmailAuthProvider.credential(
            withEmail: email,
            password: password
        )

        // Hassas işlem öncesinde kullanıcıyı tekrar doğrula.
        try await user.reauthenticate(
            with: credential
        )

        // Firebase Authentication hesabını tamamen sil.
        try await user.delete()
    }
    
    // MARK: - Password Reset

    func sendPasswordReset(email: String) async throws {

        setFirebaseLanguage()

        try await Auth.auth().sendPasswordReset(
            withEmail: email
        )
    }

    // MARK: - Helpers

    private func setFirebaseLanguage() {

        switch userDefaultsManager.appLanguage {

        case .turkish:
            Auth.auth().languageCode = "tr"

        case .english:
            Auth.auth().languageCode = "en"
        }
    }
}
