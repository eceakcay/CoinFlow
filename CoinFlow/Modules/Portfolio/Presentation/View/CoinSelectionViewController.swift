//
//  CoinSelectionViewController.swift
//  CoinFlow
//
//  Created by Ece Akcay on 31.07.2026.
//

import UIKit
import CryptoUI

final class CoinSelectionViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: CoinSelectionViewModel

    var onCoinSelected: ((CryptoCurrency) -> Void)?

    // MARK: - UI Components

    private let searchBarView = CryptoSearchBarView()
    private let tableView = UITableView(frame: .zero, style: .plain)

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Search for a coin"
        label.textColor = CryptoColors.secondaryText
        label.font = CryptoFonts.body
        label.textAlignment = .center
        label.isHidden = false
        return label
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Init

    init(viewModel: CoinSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Select Coin"
        view.backgroundColor = CryptoColors.appBackground

        setupNavigationBar()
        setupSearchBar()
        setupTableView()
        setupMessageLabel()
        setupActivityIndicator()
        bindViewModel()
        
        viewModel.viewDidLoad()

    }

    // MARK: - Setup

    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: CryptoColors.primaryText
        ]

        navigationController?.navigationBar.tintColor = CryptoColors.primaryText
    }

    private func setupSearchBar() {
        view.addSubview(searchBarView)

        searchBarView.translatesAutoresizingMaskIntoConstraints = false

        searchBarView.onTextChange = { [weak self] text in
            self?.viewModel.search(query: text)
        }

        NSLayoutConstraint.activate([
            searchBarView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 16
            ),
            searchBarView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 24
            ),
            searchBarView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -24
            )
        ])
    }

    private func setupTableView() {
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = CryptoColors.appBackground
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(
            CryptoMarketCell.self,
            forCellReuseIdentifier: CryptoMarketCell.reuseIdentifier
        )

        tableView.contentInset = UIEdgeInsets(
            top: 16,
            left: 0,
            bottom: 32,
            right: 0
        )

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: searchBarView.bottomAnchor,
                constant: 16
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
    }

    private func setupMessageLabel() {
        view.addSubview(messageLabel)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            messageLabel.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            messageLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 24
            ),
            messageLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -24
            )
        ])
    }

    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            activityIndicator.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            )
        ])
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }

            switch state {
            case .idle:
                break

            case .loading:
                self.messageLabel.isHidden = true
                self.activityIndicator.startAnimating()

            case .success:
                self.activityIndicator.stopAnimating()
                self.messageLabel.isHidden = true
                self.tableView.reloadData()

            case .empty:
                self.activityIndicator.stopAnimating()
                self.messageLabel.isHidden = false
                self.messageLabel.text = "No coins found"
                self.tableView.reloadData()

            case .failure(let message):
                self.activityIndicator.stopAnimating()
                self.messageLabel.isHidden = false
                self.messageLabel.text = message
            }
        }
    }

    // MARK: - Formatting

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"

        if value < 1 {
            formatter.maximumFractionDigits = 6
        } else {
            formatter.maximumFractionDigits = 2
        }

        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }

    private func formatPercentage(_ value: Double?) -> String {
        guard let value else {
            return "N/A"
        }

        return String(format: "%.2f%%", value)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension CoinSelectionViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return viewModel.numberOfRows()
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CryptoMarketCell.reuseIdentifier,
            for: indexPath
        )

        guard let cryptoCell = cell as? CryptoMarketCell else {
            return cell
        }

        guard let coin = viewModel.coin(at: indexPath.row) else {
            return cell
        }

        let change = coin.priceChangePercentage24h ?? 0

        let configuration = CryptoMarketCellConfiguration(
            name: coin.name,
            symbol: coin.symbol,
            priceText: formatCurrency(coin.currentPrice),
            changeText: formatPercentage(coin.priceChangePercentage24h),
            isPositive: change >= 0,
            iconBackgroundColor: CryptoCoinColors.color(for: coin.symbol),
            imageURL: URL(string: coin.imageURL)
        )

        cryptoCell.configure(with: configuration)

        return cryptoCell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let coin = viewModel.coin(at: indexPath.row) else {
            return
        }

        onCoinSelected?(coin)
    }
}
