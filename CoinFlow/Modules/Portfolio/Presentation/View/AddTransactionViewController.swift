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
    
    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    private let coinNameTextField = UITextField()
    private let symbolTextField = UITextField()
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
        
        title = "Add Transaction"
        view.backgroundColor = CryptoColors.appBackground

        setupNavigationBar()
        setupScrollView()
        setupTextFields()
        setupContent()
        bindViewModel()
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
            coinNameTextField,
            placeholder: "Coin Name, e.g. Bitcoin"
        )

        configureTextField(
            symbolTextField,
            placeholder: "Symbol, e.g. BTC"
        )

        configureTextField(
            amountTextField,
            placeholder: "Amount, e.g. 0.02"
        )

        configureTextField(
            priceTextField,
            placeholder: "Price per coin, e.g. 65000"
        )

        amountTextField.keyboardType = .decimalPad
        priceTextField.keyboardType = .decimalPad
    }

    private func setupContent() {
        contentStackView.addArrangedSubview(coinNameTextField)
        contentStackView.addArrangedSubview(symbolTextField)
        contentStackView.addArrangedSubview(typeSegmentedControl)
        contentStackView.addArrangedSubview(amountTextField)
        contentStackView.addArrangedSubview(priceTextField)
        contentStackView.addArrangedSubview(saveButton)

        saveButton.heightAnchor.constraint(equalToConstant: 52).isActive = true

        saveButton.addTarget(self,action: #selector(didTapSave),for: .touchUpInside)
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

    // MARK: - Actions

    @objc private func didTapSave() {
        let selectedType: TransactionType = typeSegmentedControl.selectedSegmentIndex == 0 ? .buy : .sell

        viewModel.saveTransaction(
            coinName: coinNameTextField.text ?? "",
            symbol: symbolTextField.text ?? "",
            type: selectedType,
            amountText: amountTextField.text ?? "",
            priceText: priceTextField.text ?? ""
        )
    }

    // MARK: - Alert

    private func showAlert(message: String) {
        let alertController = UIAlertController(
            title: "Warning",
            message: message,
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "OK",style: .default)
        )

        present(alertController, animated: true)
    }
}
