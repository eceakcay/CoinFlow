//
//  PortfolioViewModel.swift
//  CoinFlow
//
//  Created by Ece Akcay on 30.07.2026.
//

import Foundation

final class PortfolioViewModel {
    
    // MARK: - State
    
    enum State {
        case idle
        case loading
        case success
        case empty
        case failure(String)
    }
    
    // MARK: - Properties
    
    private let fetchPortfolioTransactionsUseCase: FetchPortfolioTransactionsUseCase
    private let addPortfolioTransactionsUseCase: AddPortfolioTransactionUseCase
    private let deletePortfolioTransactionUseCase: DeletePortfolioTransactionUseCase
    private let calculatePortfolioSummaryUseCase : CalculatePortfolioSummaryUseCase

    private(set) var transactions: [PortfolioTransaction] = []
    private(set) var summary = PortfolioSummary(holdings: [])
    private var summaryTask: Task<Void, Never>?

    var onStateChange: ((State) -> Void)?
    
    // MARK: - Init

    init(
        fetchPortfolioTransactionsUseCase: FetchPortfolioTransactionsUseCase,
        addPortfolioTransactionsUseCase: AddPortfolioTransactionUseCase,
        deletePortfolioTransactionsUseCase: DeletePortfolioTransactionUseCase,
        calculatePortfolioSummaryUseCase: CalculatePortfolioSummaryUseCase
    ) {
        self.fetchPortfolioTransactionsUseCase = fetchPortfolioTransactionsUseCase
        self.addPortfolioTransactionsUseCase = addPortfolioTransactionsUseCase
        self.deletePortfolioTransactionUseCase = deletePortfolioTransactionsUseCase
        self.calculatePortfolioSummaryUseCase = calculatePortfolioSummaryUseCase
    }
    
    // MARK: - Lifecycle

    func viewDidLoad() {
        fetchTransactions()
    }
    
    // MARK: - Actions

    func fetchTransactions() {
        onStateChange?(.loading)
        summaryTask?.cancel()
        
        do {
            transactions = try fetchPortfolioTransactionsUseCase.execute()
            
            if transactions.isEmpty {
                summary = PortfolioSummary(holdings: [])
                onStateChange?(.empty)
                return
            }
            
            let currentTransactions = transactions
            
            summaryTask = Task { [weak self] in
                guard let self else { return }
                
                let calculatedSummary = await self.calculatePortfolioSummaryUseCase.execute(transactions: currentTransactions)
                
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    self.summary = calculatedSummary
                    self.onStateChange?(.success)
                }
            }
        } catch {
            onStateChange?(.failure(error.localizedDescription))
        }
    }
    
    func addTransaction(coinId: String, coinName: String, symbol: String, type: TransactionType, amount: Double, pricePerCoin: Double) {
        let transaction = PortfolioTransaction(coinId: coinId, coinName: coinName, symbol: symbol, type: type, amount: amount, pricePerCoin: pricePerCoin)
        
        do {
            try addPortfolioTransactionsUseCase.execute(transaction)
            fetchTransactions()
        } catch {
            onStateChange?(.failure(error.localizedDescription))
        }
    }
    
    func deleteTransaction(at index: Int) {
        guard transactions.indices.contains(index) else {
            return
        }

        let transaction = transactions[index]

        do {
            try deletePortfolioTransactionUseCase.execute(id: transaction.id)
            fetchTransactions()
        } catch {
            onStateChange?(.failure(error.localizedDescription))
        }
    }
    
    // MARK: - Data Source Helpers

    func numberOfRows() -> Int {
        return transactions.count
    }
    
    func transaction(at index: Int) -> PortfolioTransaction? {
        guard transactions.indices.contains(index) else { return nil }
        
        return transactions[index]
    }
    
    func cellItem(at index: Int) -> PortfolioTransactionCellItem? {
           guard let transaction = transaction(at: index) else {
               return nil
           }

           return PortfolioTransactionCellItem(
               titleText: transaction.coinName,
               subtitleText: transaction.symbol.uppercased(),
               amountText: formatAmount(transaction.amount, symbol: transaction.symbol),
               priceText: formatCurrency(transaction.pricePerCoin),
               dateText: formatDate(transaction.date),
               typeText: transaction.type.rawValue.uppercased()
           )
       }
    
    // MARK: - Formatting

    private func formatAmount(_ amount: Double,symbol: String) -> String {
        return "\(amount) \(symbol.uppercased())"
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2

        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
    
    var totalBalanceText: String {
        return formatCurrency(summary.totalBalance)
    }

    var investedCapitalText: String {
        return formatCurrency(summary.investedCapital)
    }

    var profitLossText: String {
        return formatSignedCurrency(summary.totalProfitLoss)
    }

    var profitLossPercentageText: String {
        return formatSignedPercentage(summary.totalProfitLossPercentage)
    }

    var isProfit: Bool {
        return summary.totalProfitLoss >= 0
    }

    private var totalInvestedAmount: Double {
        return transactions.reduce(0) { result, transaction in
            let transactionValue = transaction.amount * transaction.pricePerCoin

            switch transaction.type {
            case .buy:
                return result + transactionValue
            case .sell:
                return result - transactionValue
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        return formatter.string(from: date)
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
