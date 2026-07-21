//
//  CryptoDetailViewController.swift
//  CoinFlow
//
//  Created by Ece Akcay on 20.07.2026.
//

import UIKit
import CryptoUI

final class CryptoDetailViewController: UIViewController {
    
    private let viewModel: CryptoDetailViewModel
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let headerView = CryptoDetailHeaderView()
    private let chartView = CryptoChartPlaceholderView(
        title: "Price Chart",
        message: "Line chart will be added here"
    )
    
    private lazy var marketCapCard = CryptoStatCardView(
        title: "Market Cap",
        value: viewModel.marketCapText
    )
    
    private lazy var volumeCard = CryptoStatCardView(
        title: "Volume",
        value: viewModel.volumeText
    )
    
    private lazy var rankCard = CryptoStatCardView(
        title: "Rank",
        value: viewModel.rankText
    )
    
    private lazy var changeCard = CryptoStatCardView(
        title: "Change",
        value: viewModel.changeText
    )
    
    private let favoriteButton : UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = CryptoColors.positive
        return button
    }()
    
    init(viewModel: CryptoDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.symbolText
        view.backgroundColor = CryptoColors.appBackground

        setupNavigationBar()
        setupScrollView()
        setupContent()
        bindViewModel()
        configure()

        viewModel.viewDidLoad()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
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

           contentStackView.axis = .vertical
           contentStackView.spacing = 20
           contentStackView.alignment = .fill

           NSLayoutConstraint.activate([
               scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
               scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

               contentStackView.topAnchor.constraint(
                   equalTo: scrollView.contentLayoutGuide.topAnchor,
                   constant: 24
               ),
               contentStackView.leadingAnchor.constraint(
                   equalTo: scrollView.frameLayoutGuide.leadingAnchor,
                   constant: 24
               ),
               contentStackView.trailingAnchor.constraint(
                   equalTo: scrollView.frameLayoutGuide.trailingAnchor,
                   constant: -24
               ),
               contentStackView.bottomAnchor.constraint(
                   equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                   constant: -32
               )
           ])
       }
    
    private func setupContent() {
           contentStackView.addArrangedSubview(headerView)
           contentStackView.addArrangedSubview(chartView)

           let firstRow = UIStackView(arrangedSubviews: [
               marketCapCard,
               volumeCard
           ])

           firstRow.axis = .horizontal
           firstRow.spacing = 12
           firstRow.distribution = .fillEqually

           let secondRow = UIStackView(arrangedSubviews: [
               rankCard,
               changeCard
           ])

           secondRow.axis = .horizontal
           secondRow.spacing = 12
           secondRow.distribution = .fillEqually

           contentStackView.addArrangedSubview(firstRow)
           contentStackView.addArrangedSubview(secondRow)
       }
    
    private func bindViewModel() {
        viewModel.onFavoriteChange = { [weak self] _ in
            guard let self else { return }
            
            self.favoriteButton.setImage(UIImage(systemName: self.viewModel.favoriteIconName), for: .normal)
        }
    }
    
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
    
    @objc private func didTapFavorite() {
        viewModel.toggleFavorite()
    }
    
}
