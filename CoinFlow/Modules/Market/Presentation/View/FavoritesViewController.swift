//
//  FavoritesViewController.swift
//  CoinFlow
//
//  Created by Ece Akcay on 22.07.2026.
//

import UIKit
import CryptoUI

final class FavoritesViewController: UIViewController {

    private let viewModel: FavoritesViewModel
    
    var onCoinSelected: ((CryptoCurrency) -> Void)?

    private let tableView = UITableView(frame: .zero, style: .plain)

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()

    private let emptyStateView = CryptoEmptyStateView()

    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Favorites"
        view.backgroundColor = CryptoColors.appBackground

        setupNavigationBar()
        setupTableView()
        setupActivityIndicator()
        setupEmptyStateView()
        bindViewModel()
    }

    //favori ekranında bu yapı kullanılır genelde
    override func viewWillAppear(_ animated: Bool) { //ekranda arayüz görülmeden hemen önce çalışır
        super.viewWillAppear(animated)

        viewModel.viewWillAppear()
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        navigationController?.navigationBar.tintColor = UIColor.white
    }

    private func setupTableView() {
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = CryptoColors.appBackground
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false

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
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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

    private func setupEmptyStateView() {
        view.addSubview(emptyStateView)

        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true

        emptyStateView.configure(
            title: "No favorite coins yet",
            message: "Tap the heart icon on a coin detail page to add it here.",
            systemImageName: "heart"
        )

        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            emptyStateView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            emptyStateView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 32
            ),
            emptyStateView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -32
            )
        ])
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }

            switch state {
            case .idle:
                break

            case .loading:
                self.emptyStateView.isHidden = true
                self.activityIndicator.startAnimating()

            case .success:
                self.activityIndicator.stopAnimating()
                self.emptyStateView.isHidden = true
                self.tableView.isHidden = false
                self.tableView.reloadData()

            case .empty:
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = true
                self.emptyStateView.isHidden = false
                self.tableView.reloadData()

            case .failure(let message):
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = true
                self.emptyStateView.isHidden = false

                self.emptyStateView.configure(
                    title: "Something went wrong",
                    message: message,
                    systemImageName: "exclamationmark.triangle"
                )
            }
        }
    }

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

    private func iconColor(for symbol: String) -> UIColor {
        switch symbol.lowercased() {
        case "btc":
            return CryptoColors.bitcoinOrange
        case "eth":
            return CryptoColors.ethBlue
        case "sol":
            return CryptoColors.solanaPurple
        default:
            return UIColor.darkGray
        }
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            iconBackgroundColor: iconColor(for: coin.symbol),
            imageURL: URL(string: coin.imageURL)
        )

        cryptoCell.configure(with: configuration)

        return cryptoCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

        guard let coin = viewModel.coin(at: indexPath.row) else {
            return
        }
        
        onCoinSelected?(coin)
    }
}
