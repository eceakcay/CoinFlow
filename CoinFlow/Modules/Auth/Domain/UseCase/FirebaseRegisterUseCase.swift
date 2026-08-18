//
//  FirebaseRegisterUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 13.08.2026.
//

import Foundation

final class FirebaseRegisterUseCase {
    
    private let repository: FirebaseAuthRepositoryProtocol
    
    init(repository: FirebaseAuthRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(firstName: String,lastName: String,email: String,password: String) async throws -> AuthSession {
        
        try await repository.register(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password
        )
    }
}
