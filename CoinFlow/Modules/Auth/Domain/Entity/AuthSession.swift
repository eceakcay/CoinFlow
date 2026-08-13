//
//  AuthSession.swift
//  CoinFlow
//
//  Created by Ece Akcay on 12.08.2026.
//

import Foundation

//domain modeli. Login başarılı olunca uygulama bunu alacak.
struct AuthSession {
    let userId: String
    let username: String
    let email: String
    let fullName: String
    let accessToken: String
    let refreshToken: String
}
