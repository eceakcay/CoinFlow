//
//  AddPortfolioTransactionUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 30.07.2026.
//

import Foundation

//yapılan işi temsil eder
final class AddPortfolioTransactionUseCase {

    private let repository: PortfolioRepositoryProtocol

    init(repository: PortfolioRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ transaction: PortfolioTransaction) throws {

        guard transaction.amount.isFinite,
              transaction.pricePerCoin.isFinite,
              transaction.amount > 0,
              transaction.pricePerCoin > 0 else {
            throw PortfolioError.invalidTransactionValues
        }

        if transaction.type == .sell {

            let ownedAmount = try currentHoldingAmount(
                for: transaction.coinId
            )

            let tolerance = max(abs(ownedAmount), 1) * 1e-12
            guard transaction.amount <= ownedAmount + tolerance else {
                throw PortfolioError.insufficientHoldingAmount
            }
        }

        try repository.addTransaction(transaction)
    }

    // MARK: - Helpers

    private func currentHoldingAmount(
        for coinId: String
    ) throws -> Double {

        let transactions = try repository.fetchTransactions()

        let coinTransactions = transactions.filter {
            $0.coinId == coinId
        }

        let totalBuyAmount = coinTransactions
            .filter {
                $0.type == .buy
            }
            .reduce(0) {
                $0 + $1.amount
            }

        let totalSellAmount = coinTransactions
            .filter {
                $0.type == .sell
            }
            .reduce(0) {
                $0 + $1.amount
            }

        return totalBuyAmount - totalSellAmount
    }
}
