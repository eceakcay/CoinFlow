//
//  FetchDashboardDataUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 5.08.2026.
//

import Foundation

final class FetchDashboardDataUseCase {
    
    private let fetchPortfolioTransactionsUseCase : FetchPortfolioTransactionsUseCase
    private let calculatePortfolioSummaryUseCase : CalculatePortfolioSummaryUseCase
    
    init(fetchPortfolioTransactionsUseCase: FetchPortfolioTransactionsUseCase, calculatePortfolioSummaryUseCase: CalculatePortfolioSummaryUseCase) {
        self.fetchPortfolioTransactionsUseCase = fetchPortfolioTransactionsUseCase
        self.calculatePortfolioSummaryUseCase = calculatePortfolioSummaryUseCase
    }
    
    func execute() async -> DashboardData {
        
        do {
            let transactions = try fetchPortfolioTransactionsUseCase.execute() //coredatadan geliyor
            
            let summaryResult = try await calculatePortfolioSummaryUseCase.execute(transactions: transactions)
            
            let summary = summaryResult.summary
            
            let topHoldings = Array(
                summary.holdings
                    .sorted { $0.currentValue > $1.currentValue }
                    .prefix(4)
            )
            
            let recentTransaction = Array(
                transactions
                    .sorted { $0.date > $1.date }
                    .prefix(3)
            )
            
            return DashboardData(
                portfolioSummary: summary,
                topHoldings: topHoldings,
                recentTransactions: recentTransaction
            )
        } catch {
            return DashboardData(
                portfolioSummary: PortfolioSummary(holdings: []),
                topHoldings: [],
                recentTransactions: []
            )
        }
    }
    
    
}
