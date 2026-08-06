//
//  DashboardViewController.swift
//  CoinFlow
//
//  Created by Ece Akcay on 9.07.2026.
//

import UIKit
import CryptoUI

final class DashboardViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: DashboardViewModel

    var onAddHoldingTapped: (() -> Void)?
    var onExploreMarketTapped: (() -> Void)?
    var onSeeAllHoldingsTapped: (() -> Void)?
    var onSeeAllHoldingsTransactions: (() -> Void)?

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = CryptoFonts.caption
        label.textColor = CryptoColors.secondaryText
        return label
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = CryptoColors.primaryText
        return label
    }()

    private let portfolioCardView = CryptoDashboardPortfolioCard()

    private let investedCapitalCardView = CryptoDashboardMetricCard()
    private let profitLossCardView = CryptoDashboardMetricCard()

    private let addHoldingButton = CryptoDashboardActionButton(style: .filled)
    private let exploreMarketButton = CryptoDashboardActionButton(style: .outlined)

    private let topHoldingsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Top Holdings"
        label.font = CryptoFonts.cardTitle
        label.textColor = CryptoColors.primaryText
        return label
    }()
    
    private let topTransactionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Top Transactions"
        label.font = CryptoFonts.cardTitle
        label.textColor = CryptoColors.primaryText
        return label
    }()

    private let seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See All", for: .normal)
        button.setTitleColor(CryptoColors.positive, for: .normal)
        button.titleLabel?.font = CryptoFonts.caption
        return button
    }()
    
    private let seeAllTransactionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See All", for: .normal)
        button.setTitleColor(CryptoColors.positive, for: .normal)
        button.titleLabel?.font = CryptoFonts.caption
        return button
    }()

    private let holdingsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    private let recentTransactionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = CryptoColors.positive
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let emptyStateView = CryptoEmptyStateView()

    // MARK: - Init

    init(viewModel: DashboardViewModel) {
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

        setupScrollView()
        setupContent()
        setupActivityIndicator()
        setupEmptyStateView()
        bindViewModel()

        scrollView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
        viewModel.viewWillAppear()
    }
    
    //ekran kaybolmadan hemen önce
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - Setup ScrollView

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        
        scrollView.contentInset.bottom = 180
        scrollView.verticalScrollIndicatorInsets.bottom = 180
        

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor,constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor,constant: 24),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor,constant: -24),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor,constant: -180),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor,constant: -48)
        ])
    }

    // MARK: - Setup Content

    private func setupContent() {
        setupHeaderSection()
        setupSummarySection()
        setupActionButtons()
        setupTopHoldingsSection()
        setupRecentTransactionsSection()
    }

    private func setupHeaderSection() {
        let headerStackView = UIStackView(
            arrangedSubviews: [
                greetingLabel,
                userNameLabel
            ]
        )

        headerStackView.axis = .vertical
        headerStackView.spacing = 4

        contentStackView.addArrangedSubview(headerStackView)
    }

    private func setupSummarySection() {
        contentStackView.addArrangedSubview(portfolioCardView)

        let metricStackView = UIStackView(
            arrangedSubviews: [
                investedCapitalCardView,
                profitLossCardView
            ]
        )

        metricStackView.axis = .horizontal
        metricStackView.distribution = .fillEqually
        metricStackView.spacing = 12

        contentStackView.addArrangedSubview(metricStackView)
    }

    private func setupActionButtons() {
        addHoldingButton.configure(title: "Add Holding")
        exploreMarketButton.configure(title: "Explore Market")

        addHoldingButton.addTarget(self,action: #selector(didTapAddHolding),for: .touchUpInside)

        exploreMarketButton.addTarget(self,action: #selector(didTapExploreMarket),for: .touchUpInside)

        let buttonStackView = UIStackView(
            arrangedSubviews: [
                addHoldingButton,
                exploreMarketButton
            ]
        )

        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 12

        contentStackView.addArrangedSubview(buttonStackView)
    }

    private func setupTopHoldingsSection() {
        let sectionHeaderStackView = UIStackView(
            arrangedSubviews: [
                topHoldingsTitleLabel,
                seeAllButton
            ]
        )

        sectionHeaderStackView.axis = .horizontal
        sectionHeaderStackView.alignment = .center
        sectionHeaderStackView.distribution = .equalSpacing

        seeAllButton.addTarget(self,action: #selector(didTapSeeAllHoldings),for: .touchUpInside)

        contentStackView.addArrangedSubview(sectionHeaderStackView)
        contentStackView.addArrangedSubview(holdingsStackView)
    }
    
    private func setupRecentTransactionsSection() {
        let headerStackView = UIStackView(
            arrangedSubviews: [
                topTransactionTitleLabel,
                seeAllTransactionButton
            ]
        )
        headerStackView.axis = .horizontal
        headerStackView.alignment = .center
        headerStackView.distribution = .equalSpacing
        
        seeAllTransactionButton.addTarget(self,action: #selector(didTapSeeAllTransactions),for: .touchUpInside)
                
        contentStackView.addArrangedSubview(headerStackView)
        contentStackView.addArrangedSubview(recentTransactionsStackView)
    }

    // MARK: - Setup Loading State

    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupEmptyStateView() {
        view.addSubview(emptyStateView)

        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true

        emptyStateView.configure(
            title: "Unable to Load Dashboard",
            message: "Please check your connection and try again.",
            systemImageName: "exclamationmark.triangle"
        )

        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 32),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -32)
        ])
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            
            print("Dashboard state:", state)

            switch state {
            case .idle:
                break

            case .loading:
                self.activityIndicator.startAnimating()
                self.scrollView.isHidden = true
                self.emptyStateView.isHidden = true

            case .success:
                self.activityIndicator.stopAnimating()
                self.scrollView.isHidden = false
                self.emptyStateView.isHidden = true

                self.configureDashboard()

            case .empty:
                self.activityIndicator.stopAnimating()
                self.scrollView.isHidden = false
                self.emptyStateView.isHidden = true

                self.configureDashboard()
                self.configureEmptyTopHoldings()

            case .partialSuccess(let message):
                self.activityIndicator.stopAnimating()
                self.scrollView.isHidden = false
                self.emptyStateView.isHidden = true

                self.configureDashboard()
                self.showNetworkErrorAlert(message: message)

            case .failure(let message):
                self.activityIndicator.stopAnimating()
                self.scrollView.isHidden = true
                self.emptyStateView.isHidden = false

                self.emptyStateView.configure(
                    title: "Unable to Load Dashboard",
                    message: message,
                    systemImageName: "exclamationmark.triangle"
                )

                self.showNetworkErrorAlert(message: message)
            }
        }
    }
    
    
    // MARK: - Configure

    private func configureDashboard() {
        let summary = viewModel.summaryItem

        print("configureDashboard called")
        print("total:", summary.totalBalanceText)
        print("invested:", summary.investedCapitalText)
        print("pnl:", summary.profitLossText)
        print("holdings count:", viewModel.numberOfTopHoldings())

        greetingLabel.text = summary.greetingText
        userNameLabel.text = summary.userNameText

        portfolioCardView.configure(
            totalBalanceText: summary.totalBalanceText,
            profitLossText: summary.profitLossText,
            profitLossPercentageText: summary.profitLossPercentageText,
            isProfit: summary.isProfit
        )

        investedCapitalCardView.configure(
            title: "Invested Capital",
            value: summary.investedCapitalText,
            systemImageName: "dollarsign.circle",
            accentColor: CryptoColors.positive
        )

        profitLossCardView.configure(
            title: "Total P/L",
            value: summary.profitLossText,
            systemImageName: summary.isProfit ? "arrow.up.right" : "arrow.down.right",
            accentColor: summary.isProfit ? CryptoColors.positive : CryptoColors.negative
        )

        configureTopHoldings()
        configureRecentTransactions()
    }

    private func configureTopHoldings() {
        holdingsStackView.arrangedSubviews.forEach { view in
            holdingsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        guard viewModel.numberOfTopHoldings() > 0 else {
            configureEmptyTopHoldings()
            return
        }

        for index in 0..<viewModel.numberOfTopHoldings() {
            guard let item = viewModel.topHoldingItem(at: index) else {
                continue
            }

            let rowView = CryptoDashboardHoldingRowView()

            rowView.configure(
                coinName: item.coinNameText,
                symbolText: item.symbolText,
                amountText: item.amountText,
                currentValueText: item.currentValueText,
                profitLossText: item.profitLossText,
                isProfit: item.isProfit
            )

            holdingsStackView.addArrangedSubview(rowView)
        }
    }

    private func configureEmptyTopHoldings() {
        holdingsStackView.arrangedSubviews.forEach { view in
            holdingsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let emptyView = CryptoEmptyStateView()
        emptyView.configure(
            title: "No holdings yet",
            message: "Add your first transaction to track your portfolio.",
            systemImageName: "tray"
        )

        holdingsStackView.addArrangedSubview(emptyView)

        emptyView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: 140
        ).isActive = true
    }
    
    private func configureRecentTransactions() {
        recentTransactionsStackView.arrangedSubviews.forEach { view in
            recentTransactionsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        guard viewModel.numberOfRecentTransactions() > 0 else {
            configureEmptyRecentTransactions()
            return
        }
        
        for index in 0..<viewModel.numberOfRecentTransactions() {
            guard let item = viewModel.recentTransactionItem(at: index) else {
                continue
            }
            
            let rowView = CryptoDashboardTransactionRowView()
            rowView.configure(
                coinName: item.coinNameText,
                symbolText: item.symbolText,
                amountText: item.amountText,
                totalText: item.totalText,
                dateText: item.dateText,
                typeText: item.typeText,
                isBuy: item.isBuy
            )
            
            recentTransactionsStackView.addArrangedSubview(rowView)
        }
    }
    
    private func configureEmptyRecentTransactions() {
        let emptyView = CryptoEmptyStateView(
            title: "No transactions yet",
            message: "Your latest transactions will appear here.",
            systemImageName: "clock"
        )
        
        recentTransactionsStackView.addArrangedSubview(emptyView)
    }

    // MARK: - Actions

    @objc private func didTapAddHolding() {
        onAddHoldingTapped?()
    }

    @objc private func didTapExploreMarket() {
        onExploreMarketTapped?()
    }

    @objc private func didTapSeeAllHoldings() {
        onSeeAllHoldingsTapped?()
    }
    
    @objc private func didTapSeeAllTransactions() {
        onSeeAllHoldingsTransactions?()
    }
    
}
