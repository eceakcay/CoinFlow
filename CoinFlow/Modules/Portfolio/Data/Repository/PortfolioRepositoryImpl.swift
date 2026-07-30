//
//  PortfolioRepositoryImpl.swift
//  CoinFlow
//
//  Created by Ece Akcay on 30.07.2026.
//

import Foundation

final class PortfolioRepositoryImpl: PortfolioRepositoryProtocol {
    
    private let localDataSource: PortfolioLocalDataSource
    
    init(localDataSource: PortfolioLocalDataSource) {
        self.localDataSource = localDataSource
    }

    
    func fetchTransactions() throws -> [PortfolioTransaction] {
        return try localDataSource.fetchTransactions()
    }
    
    func addTransaction(_ transaction: PortfolioTransaction) throws {
        try localDataSource.addTransaction(transaction)
    }
    
    func deleteTransaction(id: String) throws {
        try localDataSource.deleteTransaction(id: id)
    }
    
    
}
