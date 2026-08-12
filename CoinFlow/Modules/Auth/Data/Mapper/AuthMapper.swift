//
//  AuthMapper.swift
//  CoinFlow
//
//  Created by Ece Akcay on 12.08.2026.
//

import Foundation

enum AuthMapper {

    static func map(_ dto: LoginResponseDTO) -> AuthSession {
        AuthSession(
            userId: dto.id,
            username: dto.username,
            email: dto.email,
            fullName: "\(dto.firstName) \(dto.lastName)",
            accessToken: dto.accessToken,
            refreshToken: dto.refreshToken
        )
    }
}
