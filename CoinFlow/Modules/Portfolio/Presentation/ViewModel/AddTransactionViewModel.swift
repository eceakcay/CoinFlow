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
    private let userDefaultsManager: UserDefaultsManager

    private(set) var selectedCoin: SelectedPortfolioCoin?

    var onStateChange: ((State) -> Void)?
    var onSelectedCoinChange: ((SelectedPortfolioCoin) -> Void)?
    var onCurrentPriceSelected: ((Double) -> Void)?

    // MARK: - Init

    init(
        addPortfolioTransactionUseCase: AddPortfolioTransactionUseCase,
        userDefaultsManager: UserDefaultsManager
    ) {
        self.addPortfolioTransactionUseCase = addPortfolioTransactionUseCase
        self.userDefaultsManager = userDefaultsManager
    }

    // MARK: - Actions

    func selectCoin(_ coin: SelectedPortfolioCoin) {
        selectedCoin = coin//seçilen coin viewmodelde saklanır
        onSelectedCoinChange?(coin)//VC haber verilir
    }
    
    func useCurrentPrice() {
        guard let selectedCoin else {
            onStateChange?(.failure(L10n.text(.pleaseSelectCoin)))
            return
        }

        onCurrentPriceSelected?(selectedCoin.currentPrice)
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

        let transaction = PortfolioTransaction( //seçilenlerle domain modeli oluşturduk
            coinId: selectedCoin.id,
            coinName: selectedCoin.name,
            symbol: selectedCoin.symbol,
            type: type,
            amount: amount,
            pricePerCoin: price,
            currencyCode: userDefaultsManager.appCurrency.rawValue
        )

        do {
            try addPortfolioTransactionUseCase.execute(transaction) //kaydetme işlemi yapılır
            onStateChange?(.success)
        } catch PortfolioError.insufficientHoldingAmount {
            onStateChange?(.failure(L10n.text(.insufficientHoldingAmount)))
        } catch PortfolioError.invalidTransactionValues {
            onStateChange?(.failure(L10n.text(.validAmount)))
        } catch {
            onStateChange?(.failure(error.localizedDescription))
        }
    }

    // MARK: - Helpers

    private func normalizeDecimalText(_ text: String) -> String {
        return text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
    }
}
