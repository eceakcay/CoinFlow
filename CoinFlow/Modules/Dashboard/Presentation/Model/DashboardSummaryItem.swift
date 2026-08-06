//
//  DashboardSummaryItem.swift
//  CoinFlow
//
//  Created by Ece Akcay on 5.08.2026.
//

import Foundation

// portfolio summary içindeki verileri falan ekrana basmadan önce formatlamak lazım. bu da formatlamak için kullanılan model
//mapperda formatlanıyor
struct DashboardSummaryItem {
    let greetingText: String
    let userNameText: String
    let totalBalanceText: String
    let investedCapitalText: String
    let profitLossText: String
    let profitLossPercentageText: String
    let isProfit: Bool
    
    static let empty = DashboardSummaryItem(
        greetingText: "Good morning,",
        userNameText: "Ece 👋",
        totalBalanceText: "$0.00",
        investedCapitalText: "$0.00",
        profitLossText: "$0.00",
        profitLossPercentageText: "0.00%",
        isProfit: true
    )
}
