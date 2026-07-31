//
//  PortfolioSummaryCalculator.swift
//  CoinFlow
//
//  Created by Ece Akcay on 31.07.2026.
//

import Foundation

final class PortfolioSummaryCalculator {

    func calculate(transactions: [PortfolioTransaction],marketCoins: [CryptoCurrency]) -> PortfolioSummary {
        let positions = calculatePositions(from: transactions)
        let marketCoinById = makeMarketCoinDictionary(from: marketCoins)

        let holdings = positions.compactMap { coinId, position -> PortfolioHolding? in
            guard position.amount > 0 else {
                return nil
            }

            let averageBuyPrice = position.totalCost / position.amount
            let marketCoin = marketCoinById[coinId]
            let currentPrice = marketCoin?.currentPrice ?? averageBuyPrice

            let imageURL: String?

            if let image = marketCoin?.imageURL, !image.isEmpty {
                imageURL = image
            } else {
                imageURL = nil
            }

            return PortfolioHolding(
                coinId: coinId,
                coinName: position.coinName,
                symbol: position.symbol,
                amount: position.amount,
                averageBuyPrice: averageBuyPrice,
                currentPrice: currentPrice,
                imageURL: imageURL
            )
        }

        return PortfolioSummary(
            holdings: holdings.sorted {
                $0.coinName < $1.coinName
            }
        )
    }

    private func calculatePositions(from transactions: [PortfolioTransaction]) -> [String: PortfolioPosition] {
        let sortedTransactions = transactions.sorted {
            $0.date < $1.date
        }

        var positions: [String: PortfolioPosition] = [:]

        for transaction in sortedTransactions {
            var position = positions[transaction.coinId] ?? PortfolioPosition(
                coinName: transaction.coinName,
                symbol: transaction.symbol,
                amount: 0,
                totalCost: 0
            )

            switch transaction.type {
            case .buy:
                position.amount += transaction.amount
                position.totalCost += transaction.amount * transaction.pricePerCoin

            case .sell:
                guard position.amount > 0 else {
                    continue
                }

                let averageBuyPrice = position.totalCost / position.amount
                let sellAmount = min(transaction.amount, position.amount)

                position.amount -= sellAmount
                position.totalCost -= averageBuyPrice * sellAmount
            }

            positions[transaction.coinId] = position
        }

        return positions
    }

    private func makeMarketCoinDictionary(from marketCoins: [CryptoCurrency]) -> [String: CryptoCurrency] {
        var dictionary: [String: CryptoCurrency] = [:]

        for coin in marketCoins {
            dictionary[coin.id] = coin
        }

        return dictionary
    }
}

private struct PortfolioPosition {
    let coinName: String
    let symbol: String
    var amount: Double
    var totalCost: Double
}
