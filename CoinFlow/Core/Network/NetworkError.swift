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

extension NetworkError : LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
           return "URL oluşturulamadı"
        case .invalidResponse:
            return "Sunucudan geçersiz cevap geldi"
        case .statusCode(let code):
            return "Sunucu hata kodu döndürdü: \(code)"
        case .decodingError:
            return "Gelen veri modele dönüştürülemedi."
        case .unknown(let error):
            return "Bilinmeyen hata: \(error.localizedDescription)"
            
        }
    }
    
}
