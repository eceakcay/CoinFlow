//
//  DashboardPresentationMapper.swift
//  CoinFlow
//
//  Created by Ece Akcay on 5.08.2026.
//

import Foundation

//PortfolioSummary → DashboardSummaryItem
//PortfolioHolding → DashboardHoldingItem

//Domain modellerini ekrana uygun modellere çeviriyor
final class DashboardPresentationMapper {

    //Bu fonksiyon PortfolioSummary alır ve Dashboard’da gösterilecek summary item üretir
    func makeSummaryItem(from summary: PortfolioSummary) -> DashboardSummaryItem {
        return DashboardSummaryItem(
            greetingText: makeGreetingText(),
            userNameText: "Ece 👋",
            totalBalanceText: formatCurrency(summary.totalBalance),
            investedCapitalText: formatCurrency(summary.investedCapital),
            profitLossText: formatSignedCurrency(summary.totalProfitLoss),
            profitLossPercentageText: formatSignedPercentage(
                summary.totalProfitLossPercentage
            ),
            isProfit: summary.totalProfitLoss >= 0
        )
    }

    //Bu fonksiyon Portfolio’daki holding listesini Dashboard’da gösterilecek cell item’lara çevirir.
    func makeHoldingItems(from holdings: [PortfolioHolding]) -> [DashboardHoldingItem] {
        return holdings.map { holding in
            DashboardHoldingItem(
                coinNameText: holding.coinName,
                amountText: formatAmount(
                    holding.amount,
                    symbol: holding.symbol
                ),
                currentValueText: formatCurrency(holding.currentValue),
                profitLossText: formatSignedCurrency(holding.profitLoss),
                isProfit: holding.profitLoss >= 0,
                imageURL: holding.imageURL
            )
        }
    }

    // MARK: - Private Helpers

    private func makeGreetingText() -> String {
        let hour = Calendar.current.component(.hour,from: Date())

        switch hour {
        case 5..<12:
            return "Good morning,"
        case 12..<18:
            return "Good afternoon,"
        default:
            return "Good evening,"
        }
    }

    private func formatAmount(_ amount: Double,symbol: String) -> String {
        return "\(amount) \(symbol.uppercased())"
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"

        if abs(value) < 1 {
            formatter.maximumFractionDigits = 6
        } else {
            formatter.maximumFractionDigits = 2
        }

        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }

    private func formatSignedCurrency(_ value: Double) -> String {
        if value == 0 {
            return formatCurrency(0)
        }

        let formattedValue = formatCurrency(abs(value))

        return value > 0
            ? "+\(formattedValue)"
            : "-\(formattedValue)"
    }

    private func formatSignedPercentage(_ value: Double) -> String {
        if value == 0 {
            return "0.00%"
        }

        return value > 0
            ? String(format: "+%.2f%%", value)
            : String(format: "%.2f%%", value)
    }
}
