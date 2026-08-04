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
    case rateLimit
    case noInternet
    case unknown(Error)
}

extension NetworkError : LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
           return "Invalid URL."
        case .invalidResponse:
            return "Invalid server response."
        case .statusCode(let code):
            return "Server error. Status code: \(code)"
        case .decodingError:
            return "Data could not be decoded."
        case .rateLimit:
            return "Too many requests. Please try again later."
        case .noInternet:
            return "No internet connection. Please check your connection and try again."
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
            
        }
    }
    
}
