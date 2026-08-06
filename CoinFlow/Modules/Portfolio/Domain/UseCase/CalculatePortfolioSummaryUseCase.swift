//
//  CalculatePortfolioSummaryUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 31.07.2026.
//

import Foundation

struct PortfolioSummaryCalculationResult {
    let summary: PortfolioSummary
    let warningMessage: String?
}

//Portföy işlemlerindeki coinleri bulur, onların güncel fiyatlarını API’den getirir
//bu bilgilerle portföy özetini hesaplar.
final class CalculatePortfolioSummaryUseCase {

    private let marketRepository: MarketRepositoryProtocol
    private let calculator: PortfolioSummaryCalculator

    init(marketRepository: MarketRepositoryProtocol,calculator: PortfolioSummaryCalculator) {
        self.marketRepository = marketRepository
        self.calculator = calculator
    }

    func execute(transactions: [PortfolioTransaction]) async -> PortfolioSummaryCalculationResult {
        let coinIds = makeUniqueCoinIds(from: transactions)

        print("Portfolio coin ids:", coinIds)

        guard !coinIds.isEmpty else {
            return PortfolioSummaryCalculationResult(
                summary: PortfolioSummary(holdings: []), warningMessage: nil
            )
        }

        do {
            let marketCoins = try await marketRepository.fetchMarketCoins(ids: coinIds) //güncel fiyat getirir
            
            let summary = calculator.calculate(transactions: transactions, marketCoins: marketCoins) //portföy özetini hesaplar.

            print("Portfolio market coins count:", marketCoins.count)
            print("Portfolio market coins:", marketCoins.map { "\($0.id) - \($0.currentPrice)" })

            return PortfolioSummaryCalculationResult(summary: summary, warningMessage: nil)
            
        } catch {
            print("Portfolio market price fetch error:", error.localizedDescription)

            //güncel fiyat alınamazsa bile hesaplama tamamen durmuyor
            let fallBackSummary = calculator.calculate(transactions: transactions, marketCoins: [])
            
            return PortfolioSummaryCalculationResult(summary: fallBackSummary, warningMessage: "Current prices could not be updated. Please check your internet connection.")
        }
    }

    private func makeUniqueCoinIds(from transactions: [PortfolioTransaction]) -> [String] {
        let coinIds = transactions.map {
            $0.coinId
        }

        return Array(Set(coinIds))
    }
}
