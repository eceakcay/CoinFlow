//
//  PortfolioRepositoryProtocol.swift
//  CoinFlow
//
//  Created by Ece Akcay on 30.07.2026.
//

import Foundation

//PortfolioViewController -> PortfolioViewModel -> AddPortfolioTransactionUseCase -> PortfolioRepositoryProtocol -> PortfolioRepositoryImpl -> PortfolioLocalDataSource -> CoreData

//internetten veri çekmiyor, sadece local CoreData işlemi yapıyor.
protocol PortfolioRepositoryProtocol {
    func fetchTransactions() throws -> [PortfolioTransaction]
    func addTransaction(_ transaction: PortfolioTransaction) throws
    func deleteTransaction(id: String) throws
    func deleteAllTransactions() throws
}
