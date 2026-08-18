//
//  AddTransactionViewController.swift
//  CoinFlow
//
//  Created by Ece Akcay on 30.07.2026.
//

import UIKit
import CryptoUI

final class AddTransactionViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: AddTransactionViewModel

    var onTransactionSaved: (() -> Void)?
    var onSelectCoinTapped: (() -> Void)?

    // MARK: - UI Components

    private let transactionView = CryptoAddTransactionView()

    // MARK: - Init

    init(viewModel: AddTransactionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil,bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavigationBar()
        configureView()
        bindTransactionView()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTexts()
    }

    // MARK: - Setup

    private func setupUI() {

        view.backgroundColor = CryptoColors.appBackground
        view.addSubview(transactionView)
        transactionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            transactionView.topAnchor.constraint(equalTo: view.topAnchor),
            transactionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            transactionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            transactionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupNavigationBar() {

        navigationController?.navigationBar.titleTextAttributes = [
                .foregroundColor: CryptoColors.primaryText
            ]

        navigationController?.navigationBar.tintColor = CryptoColors.primaryText
    }

    // MARK: - Configuration

    private func configureView() {
        applyTexts()
    }

    private func applyTexts() {

        title = L10n.text(.addTransaction )

        transactionView.configure(
            CryptoAddTransactionViewConfiguration(
                infoTitleText: L10n.text(.trackYourCrypto),
                infoSubtitleText: L10n.text(.trackYourCryptoSubtitle),
                selectCoinTitleText: L10n.text(.selectCoin),
                selectCoinSubtitleText: L10n.text(.chooseFromMarketList),
                buyText: L10n.text(.buy),
                sellText: L10n.text(.sell),
                amountPlaceholderText: L10n.text(.amountPlaceholder),
                pricePlaceholderText: L10n.text(.pricePerCoinPlaceholder),
                currentPriceButtonText: L10n.text(.currentPrice),
                saveBuyTransactionText: L10n.text(.saveBuyTransaction),
                saveSellTransactionText: L10n.text(.saveSellTransaction)
            )
        )

        // Dil değiştiğinde seçili coin kaybolmasın
        if let selectedCoin =
            viewModel.selectedCoin {
            transactionView.setSelectedCoin(
                title: selectedCoin.name,
                subtitle: selectedCoin.symbol.uppercased())
        }
    }

    // MARK: - Binding

    private func bindTransactionView() {

        transactionView.onSelectCoinTapped = { [weak self] in
            self?.onSelectCoinTapped?()
        }

        transactionView.onCurrentPriceTapped = { [weak self] in
            self?.viewModel.useCurrentPrice()
        }

        transactionView.onSaveTapped = { [weak self]
            selectedTypeIndex,
            amountText,
            priceText in

            guard let self else { return }

            let selectedType: TransactionType =
                selectedTypeIndex == 0
                ? .buy
                : .sell

            viewModel.saveTransaction(
                type: selectedType,
                amountText: amountText,
                priceText: priceText
            )
        }
    }

    private func bindViewModel() {

        viewModel.onSelectedCoinChange = { [weak self] coin in
            guard let self else { return }

            transactionView.setSelectedCoin(
                title: coin.name,
                subtitle: coin.symbol.uppercased()
            )
        }

        viewModel.onCurrentPriceSelected = { [weak self] price in
            guard let self else { return }

            transactionView.setPriceText(formatPriceForInput(price))
        }

        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }

            switch state {
            case .idle:
                break
                
            case .success:
                onTransactionSaved?()

            case .failure(let message):
                showAlert(message: message)
            }
        }
    }

    // MARK: - Public Methods

    func setSelectedCoin( _ coin: SelectedPortfolioCoin) {
        viewModel.selectCoin(coin)
    }

    // MARK: - Helpers

    private func formatPriceForInput(_ price: Double) -> String {

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 8
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }

    // MARK: - Alert

    private func showAlert( message: String) {

        let alertController =
            UIAlertController(
                title:L10n.text(.warning),
                message: message,
                preferredStyle: .alert
            )

        alertController.addAction(
            UIAlertAction(
                title: L10n.text(.ok),
                style: .default
            )
        )

        present(alertController,animated: true)
    }
}
