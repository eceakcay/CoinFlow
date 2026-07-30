//
//  PortfolioViewController.swift
//  CoinFlow
//
//  Created by Ece Akcay on 9.07.2026.
//

import UIKit
import CryptoUI
//PortfolioViewController -> PortfolioViewModel -> UseCase -> Repository -> LocalDataSource -> CoreData

final class PortfolioViewController: UIViewController {
    
    private let viewModel: PortfolioViewModel
    
    var onAddTransactionTapped: (() -> Void)?
    
    private let summaryCardView = CryptoPortfolioSummaryCardView()
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Henüz portfolio işlemi yok."
        label.textColor = CryptoColors.secondaryText
        label.font = CryptoFonts.body
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    init(viewModel: PortfolioViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Portfolio"
        view.backgroundColor = CryptoColors.appBackground
        
        setupNavigationBar()
        setupSummaryCardView()
        setupTableView()
        setupMessageLabel()
        bindViewModel()
        configureSummaryCard()

        viewModel.viewDidLoad()
    }
    
    private func setupNavigationBar() {
        title = "Portfolio"

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = CryptoColors.appBackground

        appearance.titleTextAttributes = [
            .foregroundColor: CryptoColors.primaryText
        ]

        appearance.largeTitleTextAttributes = [
            .foregroundColor: CryptoColors.primaryText
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance

        navigationController?.navigationBar.tintColor = CryptoColors.positive

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapAddTransaction)
        )

        navigationItem.rightBarButtonItem?.tintColor = CryptoColors.positive
    }
    
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
                   equalTo: view.safeAreaLayoutGuide.bottomAnchor
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
    
    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            
            switch state {
            case .idle:
                break
            case .loading:
                self.messageLabel.isHidden = true
            case .success:
                self.tableView.isHidden = false
                self.messageLabel.isHidden = true
                self.configureSummaryCard()
                self.tableView.reloadData()
            case .empty:
                self.tableView.isHidden = true
                self.messageLabel.isHidden = false
                self.messageLabel.text = "Henüz portfolio işlemi yok."
                self.configureSummaryCard()
            case .failure(let message):
                self.tableView.isHidden = true
                self.messageLabel.isHidden = false
                self.messageLabel.text = message
            }
        }
    }
    
    private func configureSummaryCard() {
        summaryCardView.configure(
            with: CryptoPortfolioSummaryCardConfiguration(
                totalBalanceText: "$0.00",
                investedCapitalText: "$0.00",
                profitLossText: "$0.00",
                profitLossPercentageText: "0.00%",
                isProfit: true
            )
        )
    }
    
    @objc private func didTapAddTransaction() {
        onAddTransactionTapped?()
    }
}

extension PortfolioViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CryptoPortfolioTransactionCell.reuseIdentifier, for: indexPath)
        
        guard let portfolioCell = cell as? CryptoPortfolioTransactionCell else { return cell }
        
        guard let item = viewModel.cellItem(at: indexPath.row) else { return cell }
        
        let transaction = viewModel.transaction(at: indexPath.row)
        
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
    
    func tableView(_ tableView: UITableView,commit editingStyle: UITableViewCell.EditingStyle,forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            viewModel.deleteTransaction(at: indexPath.row)
        }
    }
    
}
