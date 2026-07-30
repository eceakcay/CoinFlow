//
//  PortfolioViewModel.swift
//  CoinFlow
//
//  Created by Ece Akcay on 30.07.2026.
//

import Foundation

struct PortfolioTransactionCellItem {
    let titleText: String
    let subtitleText: String
    let amountText: String
    let priceText: String
    let dateText: String
    let typeText: String
}

final class PortfolioViewModel {
     
    enum State {
        case idle
        case loading
        case success
        case empty
        case failure(String)
    }
    
    private let fetchPortfolioTransactionsUseCase: FetchPortfolioTransactionsUseCase
    private let addPortfolioTransactionsUseCase: AddPortfolioTransactionUseCase
    private let deletePortfolioTransactionsUseCase: DeletePortfolioTransactionUseCase
    
    private(set) var transactions: [PortfolioTransaction] = []

    var onStateChange: ((State) -> Void)?
    
    init(
        fetchPortfolioTransactionsUseCase: FetchPortfolioTransactionsUseCase,
        addPortfolioTransactionsUseCase: AddPortfolioTransactionUseCase,
        deletePortfolioTransactionsUseCase: DeletePortfolioTransactionUseCase
    ) {
        self.fetchPortfolioTransactionsUseCase = fetchPortfolioTransactionsUseCase
        self.addPortfolioTransactionsUseCase = addPortfolioTransactionsUseCase
        self.deletePortfolioTransactionsUseCase = deletePortfolioTransactionsUseCase
    }
    
    func viewDidLoad() {
        fetchTransactions()
    }
    
    func fetchTransactions() {
        onStateChange?(.loading)
        
        do {
            transactions = try fetchPortfolioTransactionsUseCase.execute()
            
            if transactions.isEmpty {
                onStateChange?(.empty)
            } else {
                onStateChange?(.success)
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

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        return formatter.string(from: date)
    }
    
    
}
