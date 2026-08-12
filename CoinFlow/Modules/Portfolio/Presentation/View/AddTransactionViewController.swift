//
//  AddTransactionViewController.swift
//  CoinFlow
//
//  Created by Ece Akcay on 30.07.2026.
//

import UIKit
import CryptoUI

final class AddTransactionViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: AddTransactionViewModel
    
    var onTransactionSaved: (() -> Void)?
    var onSelectCoinTapped: (() -> Void)?
    
    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let selectedCoinButton = CryptoSelectCoinButton()

    private let amountTextField = UITextField()
    private let priceTextField = UITextField()
    
    private let typeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Buy", "Sell"])
        control.selectedSegmentIndex = 0
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
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Transaction", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = CryptoColors.positive
        button.titleLabel?.font = CryptoFonts.body
        button.layer.cornerRadius = CryptoRadius.medium
        return button
    }()
    
    private let infoCardView: UIView = {
        let view = UIView()
        view.backgroundColor = CryptoColors.buyGreenBackground
        view.layer.cornerRadius = CryptoRadius.large
        view.layer.borderWidth = 1
        view.layer.borderColor = CryptoColors.positive.withAlphaComponent(0.30).cgColor
        return view
    }()

    private let infoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Track Your Crypto"
        label.font = CryptoFonts.body
        label.textColor = CryptoColors.primaryText
        return label
    }()

    private let infoSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select a coin and add your buy or sell transaction."
        label.font = CryptoFonts.caption
        label.textColor = CryptoColors.secondaryText
        label.numberOfLines = 0
        return label
    }()

    private let infoIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chart.line.uptrend.xyaxis")
        imageView.tintColor = CryptoColors.positive
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Init
    
    init(viewModel: AddTransactionViewModel) {
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
        setupScrollView()
        setupTextFields()
        setupContent()
        bindViewModel()
        applyTexts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTexts()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: CryptoColors.primaryText
        ]
        
        navigationController?.navigationBar.tintColor = CryptoColors.primaryText
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.alignment = .fill

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

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

    private func setupTextFields() {
        configureTextField(
            amountTextField,
            placeholder: L10n.text(.amountPlaceholder)
        )

        configureTextField(
            priceTextField,
            placeholder: L10n.text(.pricePerCoinPlaceholder)
        )

        amountTextField.keyboardType = .decimalPad
        priceTextField.keyboardType = .decimalPad
    }
    
    private func setupInfoCard() {
        infoCardView.addSubview(infoIconView)

        let textStackView = UIStackView(
            arrangedSubviews: [
                infoTitleLabel,
                infoSubtitleLabel
            ]
        )

        textStackView.axis = .vertical
        textStackView.spacing = 6

        infoCardView.addSubview(textStackView)

        infoIconView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.translatesAutoresizingMaskIntoConstraints = false

        CryptoShadow.applySoftShadow(to: infoCardView)

        NSLayoutConstraint.activate([
            infoCardView.heightAnchor.constraint(equalToConstant: 92),

            infoIconView.leadingAnchor.constraint(
                equalTo: infoCardView.leadingAnchor,
                constant: 16
            ),
            infoIconView.centerYAnchor.constraint(
                equalTo: infoCardView.centerYAnchor
            ),
            infoIconView.widthAnchor.constraint(equalToConstant: 32),
            infoIconView.heightAnchor.constraint(equalToConstant: 32),

            textStackView.leadingAnchor.constraint(
                equalTo: infoIconView.trailingAnchor,
                constant: 14
            ),
            textStackView.trailingAnchor.constraint(
                equalTo: infoCardView.trailingAnchor,
                constant: -16
            ),
            textStackView.centerYAnchor.constraint(
                equalTo: infoCardView.centerYAnchor
            )
        ])
    }
    
    
    private func setupContent() {
        setupInfoCard()

        contentStackView.addArrangedSubview(infoCardView)
        contentStackView.addArrangedSubview(selectedCoinButton)
        contentStackView.addArrangedSubview(typeSegmentedControl)
        contentStackView.addArrangedSubview(amountTextField)
        contentStackView.addArrangedSubview(priceTextField)
        contentStackView.addArrangedSubview(saveButton)

        saveButton.heightAnchor.constraint(equalToConstant: 56).isActive = true

        selectedCoinButton.addTarget(self,action: #selector(didTapSelectCoin),for: .touchUpInside)
        
        typeSegmentedControl.addTarget(self,action: #selector(didChangeTransactionType),for: .valueChanged)

        saveButton.addTarget(self,action: #selector(didTapSave),for: .touchUpInside)
        
        updateTransactionTypeAppearance()
        CryptoShadow.applyCardShadow(to: saveButton)
     }
    
    private func configureTextField(_ textField: UITextField,placeholder: String) {
        textField.backgroundColor = CryptoColors.cardBackground
        textField.textColor = CryptoColors.primaryText
        textField.tintColor = CryptoColors.positive
        textField.font = CryptoFonts.body
        textField.layer.cornerRadius = CryptoRadius.medium
        textField.layer.borderWidth = 1
        textField.layer.borderColor = CryptoColors.cardBorder.cgColor
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none

        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: CryptoColors.secondaryText
            ]
        )

        textField.leftView = UIView(
            frame: CGRect(x: 0,y: 0,width: 16,height: 0)
        )

        textField.leftViewMode = .always
        textField.heightAnchor.constraint(equalToConstant: 52).isActive = true
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.onSelectedCoinChange = { [weak self] coin in
            guard let self else { return }

            self.selectedCoinButton.configure(
                title: coin.name,
                subtitle: coin.symbol.uppercased()
            )
        }

        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }

            switch state {
            case .idle:
                break

            case .success:
                self.onTransactionSaved?()

            case .failure(let message):
                self.showAlert(message: message)
            }
        }
    }
    
    // MARK: - Configuration
    
    private func applyTexts() {
        title = L10n.text(.addTransaction)
        
        infoTitleLabel.text = L10n.text(.trackYourCrypto)
        infoSubtitleLabel.text = L10n.text(.trackYourCryptoSubtitle)
        
        typeSegmentedControl.setTitle(L10n.text(.buy), forSegmentAt: 0)
        typeSegmentedControl.setTitle(L10n.text(.sell), forSegmentAt: 1)
        
        configureTextField(
            amountTextField,
            placeholder: L10n.text(.amountPlaceholder)
        )
        
        configureTextField(
            priceTextField,
            placeholder: L10n.text(.pricePerCoinPlaceholder)
        )
        
        if viewModel.selectedCoin == nil {
            selectedCoinButton.configure(
                title: L10n.text(.selectCoin),
                subtitle: L10n.text(.chooseFromMarketList)
            )
        }
        
        updateTransactionTypeAppearance()
    }
    
    // MARK: - Public Methods
    
    func setSelectedCoin(_ coin: SelectedPortfolioCoin) {
        viewModel.selectCoin(coin)
    }

    // MARK: - Actions

    @objc private func didTapSelectCoin() {
        onSelectCoinTapped?()
    }

    @objc private func didTapSave() {
        let selectedType: TransactionType = typeSegmentedControl.selectedSegmentIndex == 0
            ? .buy
            : .sell

        viewModel.saveTransaction(
            type: selectedType,
            amountText: amountTextField.text ?? "",
            priceText: priceTextField.text ?? ""
        )
    }
    
    @objc private func didChangeTransactionType() {
        updateTransactionTypeAppearance()
    }

    // MARK: - Alert

    private func showAlert(message: String) {
        let alertController = UIAlertController(
            title: L10n.text(.warning),
            message: message,
            preferredStyle: .alert
        )

        alertController.addAction(
            UIAlertAction(
                title: L10n.text(.ok),
                style: .default
            )
        )

        present(alertController, animated: true)
    }
    
    private func updateTransactionTypeAppearance() {
        let isBuySelected = typeSegmentedControl.selectedSegmentIndex == 0

        let selectedColor = isBuySelected
            ? CryptoColors.positive
            : CryptoColors.negative

        let backgroundColor = isBuySelected
            ? CryptoColors.buyGreenBackground
            : CryptoColors.sellRedBackground

        typeSegmentedControl.selectedSegmentTintColor = selectedColor
        infoCardView.backgroundColor = backgroundColor
        infoCardView.layer.borderColor = selectedColor.withAlphaComponent(0.30).cgColor
        infoIconView.tintColor = selectedColor
        saveButton.backgroundColor = selectedColor

        let buttonTitle = isBuySelected
            ? L10n.text(.saveBuyTransaction)
            : L10n.text(.saveSellTransaction)

        saveButton.setTitle(buttonTitle, for: .normal)
    }
}


