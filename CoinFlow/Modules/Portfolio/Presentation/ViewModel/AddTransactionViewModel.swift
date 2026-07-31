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

    private(set) var selectedCoin: SelectedPortfolioCoin?

    var onStateChange: ((State) -> Void)?
    var onSelectedCoinChange: ((SelectedPortfolioCoin) -> Void)?

    // MARK: - Init

    init(addPortfolioTransactionUseCase: AddPortfolioTransactionUseCase) {
        self.addPortfolioTransactionUseCase = addPortfolioTransactionUseCase
    }

    // MARK: - Actions

    func selectCoin(_ coin: SelectedPortfolioCoin) {
        selectedCoin = coin
        onSelectedCoinChange?(coin)
    }

    func saveTransaction(
        type: TransactionType,
        amountText: String,
        priceText: String
    ) {
        guard let selectedCoin else {
            onStateChange?(.failure("Please select a coin."))
            return
        }

        let normalizedAmountText = normalizeDecimalText(amountText)
        let normalizedPriceText = normalizeDecimalText(priceText)

        guard let amount = Double(normalizedAmountText),
              amount > 0 else {
            onStateChange?(.failure("Please enter a valid amount."))
            return
        }

        guard let price = Double(normalizedPriceText),
              price > 0 else {
            onStateChange?(.failure("Please enter a valid price."))
            return
        }

        let transaction = PortfolioTransaction(
            coinId: selectedCoin.id,
            coinName: selectedCoin.name,
            symbol: selectedCoin.symbol,
            type: type,
            amount: amount,
            pricePerCoin: price
        )

        do {
            try addPortfolioTransactionUseCase.execute(transaction)
            onStateChange?(.success)
        } catch {
            onStateChange?(.failure(error.localizedDescription))
        }
    }

    // MARK: - Helpers

    private func normalizeDecimalText(_ text: String) -> String {
        return text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: "/", with: ".")
    }
}
