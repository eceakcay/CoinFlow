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

    func execute(transactions: [PortfolioTransaction], vsCurrency: String) async -> PortfolioSummaryCalculationResult {
        let coinIds = makeUniqueCoinIds(from: transactions)

        guard !coinIds.isEmpty else {
            let summary = PortfolioSummary(holdings: [])
            PortfolioWidgetSnapshotStore.save(summary: summary, currencyCode: vsCurrency.uppercased())
            return PortfolioSummaryCalculationResult(summary: summary, warningMessage: nil)
        }

        do {
            let marketCoins = try await marketRepository.fetchMarketCoins(ids: coinIds, vsCurrency: vsCurrency) //güncel fiyat getirir
            let targetCurrency = vsCurrency.uppercased()
            var exchangeRates = [targetCurrency: 1.0]
            var hasMissingExchangeRate = false

            let sourceCurrencies = Set(transactions.map { $0.currencyCode.uppercased() })
                .subtracting([targetCurrency])

            for sourceCurrency in sourceCurrencies {
                do {
                    let sourceMarketCoins = try await marketRepository.fetchMarketCoins(
                        ids: coinIds,
                        vsCurrency: sourceCurrency.lowercased()
                    )

                    if let rate = makeExchangeRate(
                        targetCoins: marketCoins,
                        sourceCoins: sourceMarketCoins
                    ) {
                        exchangeRates[sourceCurrency] = rate
                    } else {
                        hasMissingExchangeRate = true
                    }
                } catch {
                    hasMissingExchangeRate = true
                }
            }

            let summary = calculator.calculate(
                transactions: transactions,
                marketCoins: marketCoins,
                exchangeRates: exchangeRates
            ) //portföy özetini hesaplar.

            PortfolioWidgetSnapshotStore.save(
                summary: summary,
                currencyCode: vsCurrency.uppercased()
            )

            let warningMessage = hasMissingExchangeRate
                ? "Some transaction currencies could not be converted."
                : nil
            return PortfolioSummaryCalculationResult(summary: summary, warningMessage: warningMessage)
            
        } catch {
            //güncel fiyat alınamazsa bile hesaplama tamamen durmuyor
            let targetCurrency = vsCurrency.uppercased()
            let fallBackSummary = calculator.calculate(
                transactions: transactions,
                marketCoins: [],
                exchangeRates: [targetCurrency: 1.0]
            )
            
            return PortfolioSummaryCalculationResult(summary: fallBackSummary, warningMessage: "Current prices could not be updated. Please check your internet connection.")
        }
    }

    private func makeUniqueCoinIds(from transactions: [PortfolioTransaction]) -> [String] {
        let coinIds = transactions.map {
            $0.coinId
        }

        return Array(Set(coinIds))
    }

    /// Aynı kripto varlığın hedef ve kaynak para birimlerindeki güncel fiyat
    /// oranlarından medyan kur üretir. Tek bir coindeki fiyat anomalisi böylece
    /// bütün portföyün maliyet bazını bozmaz.
    private func makeExchangeRate(
        targetCoins: [CryptoCurrency],
        sourceCoins: [CryptoCurrency]
    ) -> Double? {
        let sourceById = Dictionary(uniqueKeysWithValues: sourceCoins.map { ($0.id, $0) })
        let rates = targetCoins.compactMap { targetCoin -> Double? in
            guard let sourcePrice = sourceById[targetCoin.id]?.currentPrice,
                  sourcePrice.isFinite,
                  sourcePrice > 0,
                  targetCoin.currentPrice.isFinite,
                  targetCoin.currentPrice > 0 else { return nil }
            return targetCoin.currentPrice / sourcePrice
        }.sorted()

        guard !rates.isEmpty else { return nil }
        return rates[rates.count / 2]
    }
}
