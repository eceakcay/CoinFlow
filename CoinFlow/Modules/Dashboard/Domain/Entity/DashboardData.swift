//
//  DashboardData.swift
//  CoinFlow
//
//  Created by Ece Akcay on 5.08.2026.
//

import Foundation

//hesaplama yapmaz. Yalnızca hazırlanmış Dashboard verilerini taşır.
struct DashboardData {
    let portfolioSummary: PortfolioSummary //Dashboard özeti
    let topHoldings: [PortfolioHolding] //kullanıcının sahip olduğu coinler
    let recentTransactions: [PortfolioTransaction] //kullanıcının son YAPTIĞI İŞLEMLER
}
