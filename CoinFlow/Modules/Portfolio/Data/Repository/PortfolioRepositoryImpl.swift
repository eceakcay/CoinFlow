//
//  PortfolioRepositoryImpl.swift
//  CoinFlow
//
//  Created by Ece Akcay on 30.07.2026.
//

import Foundation

final class PortfolioRepositoryImpl: PortfolioRepositoryProtocol {
    
    private let localDataSource: PortfolioLocalDataSource
    private let cloudSyncService: FirebaseCloudSyncService
    
    init(localDataSource: PortfolioLocalDataSource, cloudSyncService: FirebaseCloudSyncService) {
        self.localDataSource = localDataSource
        self.cloudSyncService = cloudSyncService
    }

    
    func fetchTransactions() throws -> [PortfolioTransaction] {
        return try localDataSource.fetchTransactions()
    }
    
    func addTransaction(_ transaction: PortfolioTransaction) throws {
        guard transaction.amount.isFinite,
              transaction.pricePerCoin.isFinite,
              transaction.amount > 0,
              transaction.pricePerCoin > 0 else {
            throw PortfolioError.invalidTransactionValues
        }

        if transaction.type == .sell {
            let ownedAmount = try localDataSource.fetchTransactions()
                .filter { $0.coinId == transaction.coinId }
                .reduce(0.0) { balance, existingTransaction in
                    switch existingTransaction.type {
                    case .buy:
                        return balance + existingTransaction.amount
                    case .sell:
                        return balance - existingTransaction.amount
                    }
                }

            // Double hesaplamalarındaki çok küçük yuvarlama farklarının tam
            // bakiyeyi satmayı yanlışlıkla engellememesi için tolerans kullan.
            let tolerance = max(abs(ownedAmount), 1) * 1e-12
            guard transaction.amount <= ownedAmount + tolerance else {
                throw PortfolioError.insufficientHoldingAmount
            }
        }

        try localDataSource.addTransaction(transaction)
        cloudSyncService.enqueueSaveTransaction(transaction)
    }
    
    func deleteTransaction(id: String) throws {
        let allTransactions = try localDataSource.fetchTransactions()

        if let transactionToDelete = allTransactions.first(where: { $0.id == id }),
           transactionToDelete.type == .buy {
            let remainingLedger = allTransactions
                .filter { $0.id != id && $0.coinId == transactionToDelete.coinId }
                .sorted { $0.date < $1.date }

            var balance = 0.0
            for transaction in remainingLedger {
                balance += transaction.type == .buy
                    ? transaction.amount
                    : -transaction.amount

                let tolerance = max(abs(balance), 1) * 1e-12
                guard balance >= -tolerance else {
                    throw PortfolioError.buyRequiredByLaterSale
                }
            }
        }

        try localDataSource.deleteTransaction(id: id)
        cloudSyncService.enqueueDeleteTransaction(id: id)
    }
    
    func deleteAllTransactions() throws {
        let transactionIds = try localDataSource.fetchTransactions().map(\.id)
        try localDataSource.deleteAllTransactions()
        transactionIds.forEach { cloudSyncService.enqueueDeleteTransaction(id: $0) }
    }

    
    
}
