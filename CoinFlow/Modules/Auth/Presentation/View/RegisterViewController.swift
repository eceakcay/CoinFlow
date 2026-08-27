//
//  RegisterViewController.swift
//  CoinFlow
//
//  Created by Ece Akcay on 13.08.2026.
//

import UIKit
import CryptoUI

final class RegisterViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: RegisterViewModel

    var onRegisterSuccess: (() -> Void)?

    // MARK: - UI Components

    private let registerView = CryptoRegisterView()

    // MARK: - Init

    init(viewModel: RegisterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        configureRegisterView()
        bindRegisterView()
        bindViewModel()
        view.enableAdaptiveTypography()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = CryptoColors.appBackground

        view.addSubview(registerView)

        registerView.translatesAutoresizingMaskIntoConstraints = false

        var constraints = [
            registerView.topAnchor.constraint(equalTo: view.topAnchor),
            registerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        constraints += registerView.adaptiveHorizontalConstraints(in: view.safeAreaLayoutGuide, maximumWidth: 620, horizontalInset: 0)
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Binding

    private func bindRegisterView() {
        registerView.onCreateAccountTapped = {
            [weak self] firstName, lastName, email, password in

            self?.viewModel.register(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password
            )
        }

        registerView.onTextChanged = { [weak self] in
            self?.registerView.hideError()
        }
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }

            DispatchQueue.main.async {
                switch state {

                case .idle:
                    self.registerView.setLoading(false)

                case .loading:
                    self.registerView.hideError()
                    self.registerView.setLoading(true)

                case .success:
                    self.registerView.setLoading(false)
                    self.onRegisterSuccess?()

                case .failure(let message):
                    self.registerView.setLoading(false)
                    self.registerView.showError(message)
                }
            }
        }
    }
    
    private func configureRegisterView() {

        registerView.configure(
            CryptoRegisterViewConfiguration(
                titleText: L10n.text(.createAccount),
                subtitleText: L10n.text(.createAccountSubtitle),

                firstNameTitleText: L10n.text(.firstName).uppercased(),
                firstNamePlaceholderText: L10n.text(.firstNamePlaceholder),

                lastNameTitleText: L10n.text(.lastName).uppercased(),
                lastNamePlaceholderText: L10n.text(.lastNamePlaceholder),

                emailTitleText: L10n.text(.email).uppercased(),
                emailPlaceholderText: L10n.text(.emailPlaceholder),

                passwordTitleText: L10n.text(.password).uppercased(),
                passwordPlaceholderText: "••••••••",

                createAccountButtonText: L10n.text(.createAccount)
            )
        )
    }
}
