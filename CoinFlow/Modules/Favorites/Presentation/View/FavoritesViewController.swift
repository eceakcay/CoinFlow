//
//  FavoritesViewController.swift
//  CoinFlow
//
//  Created by Ece Akcay on 22.07.2026.
//

import UIKit
import CryptoUI

final class FavoritesViewController: UIViewController {

    // MARK: - Properties
    
    private let viewModel: FavoritesViewModel
    
    var onCoinSelected: ((CryptoCurrency) -> Void)?

    // MARK: - UI Components
    
    private let tableView = UITableView(frame: .zero, style: .plain)

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()

    private let emptyStateView = CryptoEmptyStateView()

    // MARK: - Init
    
    init(viewModel: FavoritesViewModel) {
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
        applyTexts()

        setupNavigationBar()
        setupTableView()
        setupActivityIndicator()
        setupEmptyStateView()
        bindViewModel()
        view.enableAdaptiveTypography()
    }

    //favori ekranında bu yapı kullanılır genelde
    override func viewWillAppear(_ animated: Bool) { //ekranda arayüz görülmeden hemen önce çalışır
        super.viewWillAppear(animated)

        applyTexts()
        viewModel.viewWillAppear()
    }

    // MARK: - Setup
    
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

        var constraints = [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        constraints += tableView.adaptiveHorizontalConstraints(
            in: view.safeAreaLayoutGuide,
            horizontalInset: 0
        )
        NSLayoutConstraint.activate(constraints)
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
            title: L10n.text(.noFavoriteCoinsYet),
            message: L10n.text(.favoriteEmptyMessage),
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

    // MARK: - Binding
    
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
                
            case .partialSuccess(let message):
                self.activityIndicator.stopAnimating()

                self.tableView.isHidden = false
                self.emptyStateView.isHidden = true

                self.tableView.reloadData()

                self.showNetworkErrorAlert(message: message)

            case .failure(let message):
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = true
                self.emptyStateView.isHidden = false

                self.emptyStateView.configure(
                    title: L10n.text(.unableToLoadFavorites),
                    message: message,
                    systemImageName: "exclamationmark.triangle"
                )
                
                self.showNetworkErrorAlert(message: message)
            }
        }
    }
    
    // MARK: - Configuration
    
    private func applyTexts() {
        title = L10n.text(.favorites)
        
        emptyStateView.configure(
            title: L10n.text(.noFavoriteCoinsYet),
            message: L10n.text(.favoriteEmptyMessage),
            systemImageName: "heart"
        )
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
            iconBackgroundColor: CryptoCoinColors.color(for: coin.symbol),
            imageURL: URL(string: coin.imageURL)
        )

        cryptoCell.configure(with: configuration)
        cryptoCell.enableAdaptiveTypography()

        return cryptoCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

        guard let coin = viewModel.coin(at: indexPath.row) else {
            return
        }
        
        onCoinSelected?(coin)
    }

    
    ///UITableView’in klasik delete sistemi
   // func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,forRowAt indexPath: IndexPath) {
    //    if editingStyle == .delete {
      //      viewModel.removeFavorite(at: indexPath.row)
        //}
    //}
    
    
    func tableView(_ tableView: UITableView,trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let removeAction = UIContextualAction( //swipe action
            style: .destructive,//silme/kaldırma
            title: L10n.text(.remove)
        ) { [weak self] _, _, completionHandler in
            guard let self else {
                completionHandler(false) //bellekte yoksa işlem başarısız
                return
            }

            self.viewModel.removeFavorite(at: indexPath.row)
            completionHandler(true) //işlem başarılı
        }

        removeAction.image = UIImage(systemName: "heart.slash")

        let configuration = UISwipeActionsConfiguration(
            actions: [removeAction]
        )

        configuration.performsFirstActionWithFullSwipe = true//komple kaydıırnca direkt siler

        return configuration
    }

}
