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
    func makeSummaryItem(from summary: PortfolioSummary, currency: AppCurrency) -> DashboardSummaryItem {
        return DashboardSummaryItem(
                greetingText: makeGreetingText(),
                userNameText: "Ece 👋",
                totalBalanceText: formatCurrency(summary.totalBalance, currency: currency),
                investedCapitalText: formatCurrency(summary.investedCapital, currency: currency),
                profitLossText: formatSignedCurrency(summary.totalProfitLoss, currency: currency),
                profitLossPercentageText: formatSignedPercentage(
                    summary.totalProfitLossPercentage
                ),
                isProfit: summary.totalProfitLoss >= 0
        )
    }

    //Bu fonksiyon Portfolio’daki holding listesini Dashboard’da gösterilecek cell item’lara çevirir.
    func makeHoldingItems(from holdings: [PortfolioHolding],currency: AppCurrency) -> [DashboardHoldingItem] {
        return holdings.map { holding in
                DashboardHoldingItem(
                    coinNameText: holding.coinName,
                    symbolText: holding.symbol,
                    amountText: formatAmount(holding.amount,symbol: holding.symbol),
                    currentValueText: formatCurrency(holding.currentValue, currency: currency),
                    profitLossText: formatSignedCurrency(holding.profitLoss, currency: currency),
                    isProfit: holding.profitLoss >= 0,
                    imageURL: holding.imageURL
                )
            }
    }
    
    func makeTransactionItems(from transactions: [PortfolioTransaction],currency: AppCurrency) -> [DashboardTransactionItem] {
        transactions.map { transaction in
            let total = transaction.amount * transaction.pricePerCoin
            
            let typeText = transaction.type == .buy
                ? L10n.text(.buy)
                : L10n.text(.sell)

            let totalText = "\(L10n.text(.total)) \(formatCurrency(total, currency: currency))"
                
                return DashboardTransactionItem(
                    coinNameText: transaction.coinName,
                    symbolText: transaction.symbol.uppercased(),
                    amountText: formatAmount(transaction.amount,symbol: transaction.symbol),
                    priceText: formatCurrency(transaction.pricePerCoin, currency: currency),
                    totalText: totalText,
                    dateText: formatDate(transaction.date),
                    typeText: typeText,
                    isBuy: transaction.type == .buy
                )
            }
    }
    // MARK: - Private Helpers

    private func makeGreetingText() -> String {
        let hour = Calendar.current.component(.hour, from: Date())

        if hour < 12 {
            return L10n.text(.goodMorning)
        } else if hour < 18 {
            return L10n.text(.goodAfternoon)
        } else {
            return L10n.text(.goodEvening)
        }
    }

    private func formatAmount(_ amount: Double,symbol: String) -> String {
         return "\(amount) \(symbol.uppercased())"
     }

     private func formatCurrency(_ value: Double, currency: AppCurrency) -> String {
         let formatter = NumberFormatter()
         formatter.numberStyle = .currency
         formatter.currencyCode = currency.rawValue
         formatter.locale = Locale(identifier: currency.localeIdentifier)

         if abs(value) < 1 {
             formatter.maximumFractionDigits = 6
         } else {
             formatter.maximumFractionDigits = 2
         }

         return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
     }

    private func formatSignedCurrency(_ value: Double, currency: AppCurrency) -> String {
          let formattedValue = formatCurrencyWithTwoDigits(abs(value), currency: currency)

          if value == 0 {
              return formatCurrencyWithTwoDigits(0, currency: currency)
          }

          return value > 0 ? "+\(formattedValue)" : "-\(formattedValue)"
      }

      private func formatCurrencyWithTwoDigits(_ value: Double, currency: AppCurrency) -> String {
          let formatter = NumberFormatter()
          formatter.numberStyle = .currency
          formatter.currencyCode = currency.rawValue
          formatter.locale = Locale(identifier: currency.localeIdentifier)
          formatter.maximumFractionDigits = 2
          formatter.minimumFractionDigits = 2

          return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
      }

    private func formatSignedPercentage(_ value: Double) -> String {
         if value == 0 {
             return "0.00%"
         }

         return value > 0
             ? String(format: "+%.2f%%", value)
             : String(format: "%.2f%%", value)
     }
     
     private func formatDate(_ date: Date) -> String {
         let formatter = DateFormatter()
         formatter.dateFormat = "d MMM yyyy"
         return formatter.string(from: date)
     }
}
