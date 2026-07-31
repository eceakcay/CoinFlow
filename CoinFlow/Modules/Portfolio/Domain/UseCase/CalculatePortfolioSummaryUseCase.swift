//
//  CalculatePortfolioSummaryUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 31.07.2026.
//

import Foundation

final class CalculatePortfolioSummaryUseCase {

    private let marketRepository: MarketRepositoryProtocol
    private let calculator: PortfolioSummaryCalculator

    init(marketRepository: MarketRepositoryProtocol,calculator: PortfolioSummaryCalculator) {
        self.marketRepository = marketRepository
        self.calculator = calculator
    }

    func execute(transactions: [PortfolioTransaction]) async -> PortfolioSummary {
        let coinIds = makeUniqueCoinIds(from: transactions)

        print("Portfolio coin ids:", coinIds)

        guard !coinIds.isEmpty else {
            return PortfolioSummary(holdings: [])
        }

        do {
            let marketCoins = try await marketRepository.fetchMarketCoins(
                ids: coinIds
            )

            print("Portfolio market coins count:", marketCoins.count)
            print("Portfolio market coins:", marketCoins.map { "\($0.id) - \($0.currentPrice)" })

            return calculator.calculate(
                transactions: transactions,
                marketCoins: marketCoins
            )
        } catch {
            print("Portfolio market price fetch error:", error.localizedDescription)

            return calculator.calculate(
                transactions: transactions,
                marketCoins: []
            )
        }
    }

    private func makeUniqueCoinIds(from transactions: [PortfolioTransaction]) -> [String] {
        let coinIds = transactions.map {
            $0.coinId
        }

        return Array(Set(coinIds))
    }
}
