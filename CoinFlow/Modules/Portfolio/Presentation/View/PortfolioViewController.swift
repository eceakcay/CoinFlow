//
//  PortfolioViewController.swift
//  CoinFlow
//
//  Created by Ece Akcay on 9.07.2026.
//

import UIKit
import CryptoUI

// PortfolioViewController -> PortfolioViewModel -> UseCase -> Repository -> LocalDataSource -> CoreData

final class PortfolioViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: PortfolioViewModel
    
    var onAddTransactionTapped: (() -> Void)? //dependecny conatiner yakalıyor
    
    // MARK: - UI Components
    
    private let summaryCardView = CryptoPortfolioSummaryCardView()
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "No portfolio transactions yet."
        label.textColor = CryptoColors.secondaryText
        label.font = CryptoFonts.body
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let activityIndicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = CryptoColors.positive
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    
    // MARK: - Init
    
    init(viewModel: PortfolioViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    //ekran ilk oluştuğunda çalışır
    override func viewDidLoad() { //ekranın belleğe yüklenmesini sağlar. ekranı kur
        super.viewDidLoad()
        
        title = "Portfolio"
        view.backgroundColor = CryptoColors.appBackground
        
        setupNavigationBar()
        setupSummaryCardView()
        setupTableView()
        setupMessageLabel()
        setupActivityIndicator()
        bindViewModel()
        
       // viewModel.viewDidLoad()
    }
    
    //(bu ekrana geri dönüldüğünde de burası çalışır)
    //ekran kullanıcıya görünmeden hemen önce çalışır.
    override func viewWillAppear(_ animated: Bool) { //->veriyi çek / güncelle
        super.viewWillAppear(animated)

        viewModel.fetchTransactions()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        title = "Portfolio"
        
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: CryptoColors.primaryText
        ]
        
        navigationController?.navigationBar.tintColor = CryptoColors.primaryText

        let addButton = CryptoIconButton(
            systemImageName: "plus",
            iconColor: CryptoColors.positive,
            backgroundColor: CryptoColors.cardBackground,
            size: 44
        )

        addButton.addTarget(self,action: #selector(didTapAddTransaction),for: .touchUpInside)

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: addButton
        )    }
    
    private func setupSummaryCardView() {
        view.addSubview(summaryCardView)
        
        summaryCardView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            summaryCardView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 16
            ),
            summaryCardView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 24
            ),
            summaryCardView.trailingAnchor.constraint(
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
        
        tableView.contentInset = UIEdgeInsets(top: 8,left: 0,bottom: 110,right: 0)

        tableView.scrollIndicatorInsets = tableView.contentInset

        tableView.register(
            CryptoPortfolioTransactionCell.self,
            forCellReuseIdentifier: CryptoPortfolioTransactionCell.reuseIdentifier
        )

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: summaryCardView.bottomAnchor,
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
                equalTo: tableView.centerXAnchor
            ),
            messageLabel.centerYAnchor.constraint(
                equalTo: tableView.centerYAnchor
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
    
    // MARK: - Setup Activity Indicator
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Binding
    
    func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            
            switch state {
            case .idle:
                break
                
            case .loading:
                self.activityIndicator.startAnimating()
                self.summaryCardView.isHidden = true //gizli
                self.tableView.isHidden = true //gizli
                self.messageLabel.isHidden = true //gizli
                
            case .success:
                self.activityIndicator.stopAnimating()
                self.summaryCardView.isHidden = false
                self.tableView.isHidden = false
                self.messageLabel.isHidden = true
                
                self.configureSummaryCard()
                self.tableView.reloadData()
                
            case .empty:
                self.activityIndicator.stopAnimating()
                self.summaryCardView.isHidden = false
                self.tableView.isHidden = true
                self.messageLabel.isHidden = false
                self.messageLabel.text = "No portfolio transactions yet."
                
                self.configureSummaryCard()
                
            case .failure(let message):
                self.activityIndicator.stopAnimating()
                self.summaryCardView.isHidden = true
                self.tableView.isHidden = true
                self.messageLabel.isHidden = false
                self.messageLabel.text = message
                
                self.showNetworkErrorAlert(message: message)
                
            case .partialSuccess(let message):
                self.activityIndicator.stopAnimating()

                self.summaryCardView.isHidden = false
                self.tableView.isHidden = false
                self.messageLabel.isHidden = true

                self.configureSummaryCard()
                self.tableView.reloadData()

                self.showNetworkErrorAlert(message: message)
            }
        }
    }
    
    // MARK: - Configuration
    
    private func configureSummaryCard() {
        summaryCardView.configure(
            with: CryptoPortfolioSummaryCardConfiguration(
                totalBalanceText: viewModel.totalBalanceText,
                investedCapitalText: viewModel.investedCapitalText,
                profitLossText: viewModel.profitLossText,
                profitLossPercentageText: viewModel.profitLossPercentageText,
                isProfit: viewModel.isProfit
            )
        )
    }
    
    // MARK: - Actions
    
    @objc func didTapAddTransaction() {
        onAddTransactionTapped?()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension PortfolioViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    //gücre oluşturma
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CryptoPortfolioTransactionCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let portfolioCell = cell as? CryptoPortfolioTransactionCell else {
            return cell
        }
        
        //viewmodelden metinler alınıyor
        guard let item = viewModel.cellItem(at: indexPath.row) else {
            return cell
        }
        
        let transaction = viewModel.transaction(at: indexPath.row) //işlem tipi
        
        let configuration = CryptoPortfolioTransactionCellConfiguration(
            titleText: item.titleText,
            subtitleText: item.subtitleText,
            amountText: item.amountText,
            priceText: item.priceText,
            dateText: item.dateText,
            typeText: item.typeText,
            isBuy: transaction?.type == .buy
        )

        portfolioCell.configure(with: configuration)

        return portfolioCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteTransaction(at: indexPath.row)
        }
    }
}
