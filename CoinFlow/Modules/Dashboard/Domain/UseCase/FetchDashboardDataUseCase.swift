//
//  FetchDashboardDataUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 5.08.2026.
//

import Foundation

//Dashboard ana usecase bu
//Dashboard’un ana iş akışını yönetiyor.Transactionları çekiyor, summary hesaplatıyor,top holdings listesini çıkarıyor.
final class FetchDashboardDataUseCase {
    
    // MARK: - Dependencies

    //Single Responsibility
    private let fetchPortfolioTransactionsUseCase : FetchPortfolioTransactionsUseCase
    private let calculatePortfolioSummaryUseCase : CalculatePortfolioSummaryUseCase
    
    // MARK: - Init

    init(fetchPortfolioTransactionsUseCase: FetchPortfolioTransactionsUseCase, calculatePortfolioSummaryUseCase: CalculatePortfolioSummaryUseCase) {
        self.fetchPortfolioTransactionsUseCase = fetchPortfolioTransactionsUseCase
        self.calculatePortfolioSummaryUseCase = calculatePortfolioSummaryUseCase
    }
    
    // MARK: - Execute

    func execute(vsCurrency: String) async throws -> DashboardDataResult {
        
            let transactions = try fetchPortfolioTransactionsUseCase.execute() //coredatadan geliyor.//Portfolio transactionları getir
            
            let summaryResult = await calculatePortfolioSummaryUseCase.execute(transactions: transactions, vsCurrency: vsCurrency)
            
            let summary = summaryResult.summary //Portfolio summary hesapla
        
            print("Dashboard holdings count:", summary.holdings.count)
            print("Dashboard holdings:",summary.holdings.map { "\($0.coinName) - \($0.amount)" })
            
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
            
            let dashboardData = DashboardData(portfolioSummary: summary, topHoldings: topHoldings, recentTransactions: recentTransaction)
            
            return DashboardDataResult(
                data: dashboardData,
                warningMessage: summaryResult.warningMessage
            )
        
    }
    
    
}
