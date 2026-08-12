//
//  MockAuthAPIService.swift
//  CoinFlow
//
//  Created by Ece Akcay on 12.08.2026.
//

import Foundation

final class AuthAPIService {

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func login(username: String, password: String) async throws -> LoginResponseDTO {
        let requestDTO = LoginRequestDTO(
            username: username,
            password: password
        )

        return try await apiClient.request(
            AuthEndpoint.login(request: requestDTO)
        )
    }
}
