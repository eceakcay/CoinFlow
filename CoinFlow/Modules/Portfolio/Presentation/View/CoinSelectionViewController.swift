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
        label.text = L10n.text(.searchForCoin)
        label.textColor = CryptoColors.primaryText.withAlphaComponent(0.78)
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

        view.backgroundColor = CryptoColors.appBackground

        setupNavigationBar()
        setupSearchBar()
        setupTableView()
        setupMessageLabel()
        setupActivityIndicator()
        bindViewModel()
        view.enableAdaptiveTypography()
        applyTexts()
        
        viewModel.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTexts()
    }
    
    //MARK: - Language
    
    private func applyTexts() {
        title = L10n.text(.selectCoin)
        searchBarView.setPlaceholder(L10n.text(.searchCoinsPlaceholder))
        
        if !messageLabel.isHidden {
            messageLabel.text = L10n.text(.searchForCoin)
        }
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

        var constraints = [
            searchBarView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 16
            ),
        ]
        constraints += searchBarView.adaptiveHorizontalConstraints(in: view.safeAreaLayoutGuide)
        NSLayoutConstraint.activate(constraints)
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

        var constraints = [
            tableView.topAnchor.constraint(
                equalTo: searchBarView.bottomAnchor,
                constant: 16
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ]
        constraints += tableView.adaptiveHorizontalConstraints(
            in: view.safeAreaLayoutGuide,
            horizontalInset: 0
        )
        NSLayoutConstraint.activate(constraints)
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
                self.messageLabel.text = L10n.text(.noCoinsFound)
                self.tableView.reloadData()

            case .failure(let message):
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = true
                self.messageLabel.isHidden = false
                self.messageLabel.text = message

                self.showNetworkErrorAlert(message: message)
            }
        }
    }

    // MARK: - Formatting

    private func formatCurrency(_ value: Double) -> String {
        let currency = UserDefaultsManager.shared.appCurrency
        return value.formattedCurrency(currency)
    }

    private func formatPercentage(_ value: Double?) -> String {
        guard let value else {
            return L10n.text(.notAvailable)
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
        cryptoCell.enableAdaptiveTypography()

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
