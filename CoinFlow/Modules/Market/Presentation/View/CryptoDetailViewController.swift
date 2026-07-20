//
//  CryptoDetailViewController.swift
//  CoinFlow
//
//  Created by Ece Akcay on 20.07.2026.
//

import UIKit
import CryptoUI

final class CryptoDetailViewController: UIViewController {

    private let viewModel: CryptoDetailViewModel

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = CryptoFonts.title
        label.textColor = CryptoColors.primaryText
        label.textAlignment = .center
        return label
    }()

    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = CryptoFonts.body
        label.textColor = CryptoColors.secondaryText
        label.textAlignment = .center
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = CryptoFonts.largePrice
        label.textColor = CryptoColors.primaryText
        label.textAlignment = .center
        return label
    }()

    init(viewModel: CryptoDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.symbolText
        view.backgroundColor = CryptoColors.appBackground

        setupNavigationBar()
        setupUI()
        configure()
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        navigationController?.navigationBar.tintColor = UIColor.white
    }

    private func setupUI() {
        view.addSubview(nameLabel)
        view.addSubview(symbolLabel)
        view.addSubview(priceLabel)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            symbolLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            symbolLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            symbolLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            priceLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 24),
            priceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            priceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func configure() {
        nameLabel.text = viewModel.titleText
        symbolLabel.text = viewModel.symbolText
        priceLabel.text = formatCurrency(viewModel.price)
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = value < 1 ? 6 : 2
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}
