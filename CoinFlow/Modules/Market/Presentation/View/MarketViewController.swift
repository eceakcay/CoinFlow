//
//  MarketViewController.swift
//  CoinFlow
//
//  Created by Ece Akcay on 16.07.2026.
//

import UIKit
import CryptoUI


//MarketViewController -> MarketViewModel -> UseCase -> Repository -> API

final class MarketViewController: UIViewController {

    private let viewModel: MarketViewModel
    
    private let tableView = UITableView(frame: .zero , style: .plain)
    
    //Bu loading göstergesini oluşturuyor
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "No Data"
        label.font = .systemFont(ofSize: 16, weight:.medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    //Kullanıcının tabloyu aşağı çekerek verileri yenilemesini sağlar.
    private let refreshControl = UIRefreshControl()
    
    private let cellIdentifier = "MarketCell"
    
    init(viewModel: MarketViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Market"
        view.backgroundColor = .systemBackground
        setupTableView()
        setupActivityIndicator()
        setupMessageLabel()
        bindViewModel() // ViewModel ile bağlantı kurulur
        
        viewModel.viewDidLoad()//ViewModel’e “ekran açıldı” denir
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
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
             activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
         ])
    }
    
    private func setupMessageLabel() {
        view.addSubview(messageLabel)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
    
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
                self.refreshControl.endRefreshing()
                self.messageLabel.isHidden = !self.viewModel.coins.isEmpty
                self.messageLabel.text = "No coins found"
                self.tableView.reloadData()
                
            case .failure(let message):
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                self.messageLabel.isHidden = false
                self.messageLabel.text = message
            }
        }
    }
    
    @objc private func didPullToRefresh() {
        viewModel.fetchCoins()
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
}

extension MarketViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberofRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,for: indexPath)
        
        guard let coin = viewModel.coin(at: indexPath.row) else {
            return cell
        }

        var content = cell.defaultContentConfiguration()
        content.text = "\(coin.name) (\(coin.symbol.uppercased()))"
        content.secondaryText = "\(formatCurrency(coin.currentPrice)) • 24h: \(formatPercentage(coin.priceChangePercentage24h))"

        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator

        return cell
    }
    
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
 
       guard let coin = viewModel.coin(at: indexPath.row) else {
            return
        }
        print("Selected coin:", coin.name)
    }
    
}
