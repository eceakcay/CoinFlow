//
//  PortfolioHolding.swift
//  CoinFlow
//
//  Created by Ece Akcay on 24.07.2026.
//

import Foundation

//Tek bir coin pozisyonunu temsil eder.
struct PortfolioHolding {
    let coinId: String
    let coinName: String
    let symbol: String
    let amount: Double
    let averageBuyPrice: Double
    let currentPrice: Double
    let isCurrentPriceAvailable: Bool
    let isCostBasisAvailable: Bool
    let imageURL: String?
    
    //güncel değer
    var currentValue: Double {
        return amount * currentPrice
    }
    //yatırılan değer
    var investedValue: Double {
        return amount * averageBuyPrice
    }
    
    //kar-zarar
    var profitLoss: Double {
        return currentValue - investedValue
    }
    
    //kar zarar yüzdesi
    var profitLossPercentage: Double {
        guard investedValue > 0 else { return 0 }
        
        return (profitLoss / investedValue) * 100
    }
    
    
}
