//
//  CryptoDetailViewController.swift
//  CoinFlow
//
//  Created by Ece Akcay on 20.07.2026.
//

import UIKit
import CryptoUI

final class CryptoDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: CryptoDetailViewModel
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let headerView = CryptoDetailHeaderView()
    private let chartView = CryptoLineChartView()
    
    private let chartRangeControl: UISegmentedControl = {
        let items = ChartTimeRange.allCases.map { $0.title }
        let control = UISegmentedControl(items: items)

        control.selectedSegmentIndex = ChartTimeRange.sevenDays.rawValue
        control.selectedSegmentTintColor = CryptoColors.positive

        control.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.white,
                .font: CryptoFonts.caption
            ],
            for: .selected
        )

        control.setTitleTextAttributes(
            [
                .foregroundColor: CryptoColors.secondaryText,
                .font: CryptoFonts.caption
            ],
            for: .normal
        )

        return control
    }()
    
    private lazy var marketCapCard = CryptoStatCardView(
        title: L10n.text(.marketCap),
        value: viewModel.marketCapText
    )
    
    private lazy var volumeCard = CryptoStatCardView(
        title: L10n.text(.volume),
        value: viewModel.volumeText
    )
    
    private lazy var rankCard = CryptoStatCardView(
        title: L10n.text(.rank),
        value: viewModel.rankText
    )
    
    private lazy var changeCard = CryptoStatCardView(
        title: L10n.text(.change),
        value: viewModel.changeText
    )
    
    private let favoriteButton : UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = CryptoColors.positive
        return button
    }()
    
    // MARK: - Init
    
    init(viewModel: CryptoDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.symbolText
        view.backgroundColor = CryptoColors.appBackground

        setupNavigationBar()
        setupScrollView()
        setupContent()
        bindViewModel()
        applyTexts()
        configure()
        view.enableAdaptiveTypography()

        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTexts()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
        
        favoriteButton.setImage(UIImage(systemName: viewModel.favoriteIconName), for: .normal)
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favoriteButton)
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 110,
            right: 0
        )

        scrollView.scrollIndicatorInsets = scrollView.contentInset

        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        contentStackView.alignment = .fill

        var constraints = [
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor,
                constant: 24
            ),
            contentStackView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: -32
            )
        ]
        constraints += contentStackView.adaptiveHorizontalConstraints(in: scrollView.frameLayoutGuide, maximumWidth: 720)
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupContent() {
        
           chartRangeControl.addTarget(self, action: #selector(didChangeChartRange), for: .valueChanged)
           contentStackView.addArrangedSubview(headerView)
           contentStackView.addArrangedSubview(chartRangeControl)
           contentStackView.addArrangedSubview(chartView)

           let firstRow = UIStackView(arrangedSubviews: [marketCapCard,volumeCard])

           firstRow.axis = .horizontal
           firstRow.spacing = 12
           firstRow.distribution = .fillEqually

           let secondRow = UIStackView(arrangedSubviews: [rankCard,changeCard])

           secondRow.axis = .horizontal
           secondRow.spacing = 12
           secondRow.distribution = .fillEqually

           contentStackView.addArrangedSubview(firstRow)
           contentStackView.addArrangedSubview(secondRow)
       }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        viewModel.onFavoriteChange = { [weak self] _ in
            guard let self else { return }

            self.favoriteButton.setImage(
                UIImage(systemName: self.viewModel.favoriteIconName),
                for: .normal
            )
        }

        viewModel.onChartDataChange = { [weak self] points in
            guard let self else { return }

            let chartPoints = points.map {
                CryptoLineChartPoint(
                    x: $0.timestamp,
                    y: $0.price
                )
            }

            self.chartView.configure(points: chartPoints,isPositive: self.viewModel.isChangePositive)
        }

        viewModel.onError = { errorMessage in
            #if DEBUG
            print("Chart error:", errorMessage)
            #endif
        }
    }
    
    // MARK: - Configuration
    
    private func configure() {
        let configuration = CryptoDetailHeaderConfiguration(
            name: viewModel.titleText,
            symbol: viewModel.symbolText,
            priceText: viewModel.priceText,
            changeText: viewModel.changeText,
            isChangePositive: viewModel.isChangePositive
        )
        
        headerView.configure(with: configuration)
    }
    
    private func applyTexts() {
        chartView.setTitle(L10n.text(.priceChart))
        chartView.setEmptyMessage(L10n.text(.chartDataNotAvailable))
        
        marketCapCard.configure(
            title: L10n.text(.marketCap),
            value: viewModel.marketCapText
        )
        
        volumeCard.configure(
            title: L10n.text(.volume),
            value: viewModel.volumeText
        )
        
        rankCard.configure(
            title: L10n.text(.rank),
            value: viewModel.rankText
        )
        
        changeCard.configure(
            title: L10n.text(.change),
            value: viewModel.changeText
        )
    }
    
    // MARK: - Actions
    
    @objc private func didTapFavorite() {
        viewModel.toggleFavorite()
    }
    
    @objc private func didChangeChartRange() {
        viewModel.selectChartRange(
            at: chartRangeControl.selectedSegmentIndex
        )
    }
    
}
