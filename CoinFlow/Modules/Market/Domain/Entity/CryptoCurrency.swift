//
//  CryptoCurrency.swift
//  CoinFlow
//
//  Created by Ece Akcay on 13.07.2026.
//

import Foundation

//Bu bizim uygulama içinde kullanacağımız temiz model
struct CryptoCurrency {
    let id: String
    let symbol: String
    let name: String
    let imageURL: String
    let currentPrice: Double
    let marketCap: Double?
    let marketCapRank: Int?
    let priceChangePercentage24h: Double?
}
