//
//  MarketViewController.swift
//  CoinFlow
//
//  Created by Ece Akcay on 16.07.2026.
//

import UIKit
import CryptoUI

// MarketViewController -> MarketViewModel -> UseCase -> Repository -> API

final class MarketViewController: UIViewController {

    // MARK: - Properties
    
    private let viewModel: MarketViewModel
    
    var onCoinSelected: ((CryptoCurrency) -> Void)?
    var onFavoritesTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    private let searchBarView = CryptoSearchBarView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    // Bu loading göstergesini oluşturuyor
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
        
    // Kullanıcının tabloyu aşağı çekerek verileri yenilemesini sağlar.
    private let refreshControl = UIRefreshControl()
    
    private let emptyStateView = CryptoEmptyStateView()
    
    // MARK: - Init
    
    init(viewModel: MarketViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Market"
        
        view.backgroundColor = CryptoColors.appBackground
        
        setupNavigationBar()
        setupSearchBar()
        setupTableView()
        setupEmptyStateView()
        setupActivityIndicator()
        bindViewModel() // ViewModel ile bağlantı kurulur
        
        viewModel.viewDidLoad() // ViewModel’e “ekran açıldı” denir
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
        ]
        
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        navigationController?.navigationBar.tintColor = UIColor.white
        
        let favoritesButton = UIBarButtonItem(
            image: UIImage(systemName: "heart.fill"),
            style: .plain,
            target: self,
            action: #selector(didTapFavorites)
        )
        
        favoritesButton.tintColor = CryptoColors.positive
        navigationItem.rightBarButtonItem = favoritesButton
    }
    
    private func setupSearchBar() {
        view.addSubview(searchBarView)
        
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        
        // Kullanıcı yazdıkça ViewModel’deki search(query:) fonksiyonunu çağırdı
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
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        
        tableView.backgroundColor = CryptoColors.appBackground
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(
            CryptoMarketCell.self,
            forCellReuseIdentifier: CryptoMarketCell.reuseIdentifier
        )
        
        tableView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 110,
            right: 0
        )

        tableView.scrollIndicatorInsets = tableView.contentInset
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(
            self,
            action: #selector(didPullToRefresh),
            for: .valueChanged
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
                self.activityIndicator.startAnimating()
                self.refreshControl.endRefreshing()
                
                self.tableView.isHidden = true
                self.emptyStateView.isHidden = true
                
            case .success:
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                
                self.tableView.isHidden = false
                self.emptyStateView.isHidden = true
                
                self.tableView.reloadData()
                
            case .partialSuccess(let message):
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                
                self.tableView.isHidden = false
                self.emptyStateView.isHidden = true
                
                self.tableView.reloadData()
                self.showNetworkErrorAlert(message: message)
                
            case .empty:
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                
                self.tableView.isHidden = true
                self.emptyStateView.isHidden = false
                
                self.emptyStateView.configure(
                    title: "No coins found",
                    message: "Try searching for another coin.",
                    systemImageName: "magnifyingglass"
                )
                
            case .failure(let message):
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                
                self.tableView.isHidden = true
                self.emptyStateView.isHidden = false
                
                self.emptyStateView.configure(
                    title: "Unable to Load Market",
                    message: message,
                    systemImageName: "exclamationmark.triangle"
                )
                
                self.showNetworkErrorAlert(message: message)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func didPullToRefresh() {
        viewModel.fetchCoins()
    }
    
    @objc private func didTapFavorites() {
        onFavoritesTapped?() // Ben favori butonuna basıldığını haber veririm. Ekranı kim açacak bilmiyorum.
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

extension MarketViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberofRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            configureEmptyRecentTransactions: CryptoCoinColors.color(for: coin.symbol),
            imageURL: URL(string: coin.imageURL)
        )
        
        cryptoCell.configure(with: configuration)
        
        return cryptoCell
    }
    
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath
    ) {
        // Bir satırın seçili görünümünü kaldırır
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let coin = viewModel.coin(at: indexPath.row) else {
            return
        }
        
        onCoinSelected?(coin)
    }
    
    // prefetchRowsAt
    // Bir cell ekranda görünmeden hemen önce çalışır, kullanıcı aşağıya kaydırırken
    // func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //     viewModel.loadNextPageIfNeeded(currentIndex: indexPath.row)
    // }
}

// MARK: - UITableViewDataSourcePrefetching

extension MarketViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView,prefetchRowsAt indexPaths: [IndexPath]) {
        guard let maxIndex = indexPaths.map({ $0.row }).max() else {
            return
        }

        viewModel.loadNextPageIfNeeded(currentIndex: maxIndex)
    }
}
