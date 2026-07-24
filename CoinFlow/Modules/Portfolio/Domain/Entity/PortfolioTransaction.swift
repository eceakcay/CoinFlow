//
//  PortfolioTransaction.swift
//  CoinFlow
//
//  Created by Ece Akcay on 24.07.2026.
//

import Foundation

//tek bir alış satış işlemi
struct PortfolioTransaction : Codable {
    let id: String
    let coinId: String
    let coinName: String
    let symbol: String
    let type: TransactionType
    let amount: Double
    let pricePerCoin: Double
    let date: Date
    
    init(id: String = UUID().uuidString, coinId: String, coinName: String, symbol: String, type: TransactionType, amount: Double,
         pricePerCoin: Double, date: Date = Date())
    {
        self.id = id
        self.coinId = coinId
        self.coinName = coinName
        self.symbol = symbol
        self.type = type
        self.amount = amount
        self.pricePerCoin = pricePerCoin
        self.date = date
    }
}
