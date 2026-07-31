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

    var onStateChange: ((State) -> Void)?

    // MARK: - Init

    init(addPortfolioTransactionUseCase: AddPortfolioTransactionUseCase) {
        self.addPortfolioTransactionUseCase = addPortfolioTransactionUseCase
    }

    // MARK: - Actions

    func saveTransaction(
        coinName: String,
        symbol: String,
        type: TransactionType,
        amountText: String,
        priceText: String
    ) {
        let trimmedCoinName = coinName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSymbol = symbol.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedCoinName.isEmpty,
              !trimmedSymbol.isEmpty else {
            onStateChange?(.failure("Coin name and symbol cannot be empty."))
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

        let coinId = makeCoinId(from: trimmedCoinName)

        let transaction = PortfolioTransaction(
            coinId: coinId,
            coinName: trimmedCoinName,
            symbol: trimmedSymbol.uppercased(),
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

    private func makeCoinId(from coinName: String) -> String {
        return coinName
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "-")
    }
    
    private func normalizeDecimalText(_ text: String) -> String {
        return text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: "/", with: ".")
    }
}
