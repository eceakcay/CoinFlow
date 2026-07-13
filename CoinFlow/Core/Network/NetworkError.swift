//
//  NetworkError.swift
//  CoinFlow
//
//  Created by Ece Akcay on 30.06.2026.
//

import Foundation

enum NetworkError : Error {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decodingError
    case unknown(Error)
}
