//
//  LoginResponseDTO.swift
//  CoinFlow
//
//  Created by Ece Akcay on 12.08.2026.
//

import Foundation

struct LoginResponseDTO: Decodable {
    let id: Int
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let accessToken: String
    let refreshToken: String
}
