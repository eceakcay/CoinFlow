//
//  AddTransactionViewModel.swift
//  CoinFlow
//
//  Created by Ece Akcay on 30.07.2026.
//

import Foundation

final class AddTransactionViewModel {

    // MARK: - State

    enum State {
        case idle
        case success
        case failure(String)
    }

    // MARK: - Properties

    private let addPortfolioTransactionUseCase: AddPortfolioTransactionUseCase
    private let fetchPortfolioTransactionsUseCase: FetchPortfolioTransactionsUseCase

    private(set) var selectedCoin: SelectedPortfolioCoin?

    var onStateChange: ((State) -> Void)?
    var onSelectedCoinChange: ((SelectedPortfolioCoin) -> Void)?

    // MARK: - Init

    init(addPortfolioTransactionUseCase: AddPortfolioTransactionUseCase, fetchPortfolioTransactionsUseCase: FetchPortfolioTransactionsUseCase) {
        self.addPortfolioTransactionUseCase = addPortfolioTransactionUseCase
        self.fetchPortfolioTransactionsUseCase = fetchPortfolioTransactionsUseCase
    }

    // MARK: - Actions

    func selectCoin(_ coin: SelectedPortfolioCoin) {
        selectedCoin = coin//seçilen coin viewmodelde saklanır
        onSelectedCoinChange?(coin)//VC haber verilir
    }

    func saveTransaction(type: TransactionType,amountText: String,priceText: String) {
        guard let selectedCoin else {
            onStateChange?(.failure(L10n.text(.pleaseSelectCoin)))
            return
        }

        let normalizedAmountText = normalizeDecimalText(amountText)
        let normalizedPriceText = normalizeDecimalText(priceText)

        guard let amount = Double(normalizedAmountText), amount > 0 else {
            onStateChange?(.failure(L10n.text(.validAmount)))
            return
        }

        guard let price = Double(normalizedPriceText), price > 0 else {
            onStateChange?(.failure(L10n.text(.validPrice)))
            return
        }
        
        if type == .sell {
            do {
                let ownedAmount = try currentHoldingAmount(for: selectedCoin.id)

                guard amount <= ownedAmount else {
                    onStateChange?(
                        .failure(L10n.text(.insufficientHoldingAmount))
                    )
                    return
                }
            } catch {
                onStateChange?(.failure(error.localizedDescription))
                return
            }
        }

        let transaction = PortfolioTransaction( //seçilenlerle domain modeli oluşturduk
            coinId: selectedCoin.id,
            coinName: selectedCoin.name,
            symbol: selectedCoin.symbol,
            type: type,
            amount: amount,
            pricePerCoin: price
        )

        do {
            try addPortfolioTransactionUseCase.execute(transaction) //kaydetme işlemi yapılır
            onStateChange?(.success)
        } catch {
            onStateChange?(.failure(error.localizedDescription))
        }
    }
    
    private func currentHoldingAmount(for coinId: String) throws -> Double {
        let transactions = try fetchPortfolioTransactionsUseCase.execute()

        let coinTransactions = transactions.filter {
            $0.coinId == coinId
        }

        let totalBuyAmount = coinTransactions
            .filter { $0.type == .buy }
            .reduce(0) { $0 + $1.amount }

        let totalSellAmount = coinTransactions
            .filter { $0.type == .sell }
            .reduce(0) { $0 + $1.amount }

        return totalBuyAmount - totalSellAmount
    }

    // MARK: - Helpers

    private func normalizeDecimalText(_ text: String) -> String {
        return text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
    }
}
