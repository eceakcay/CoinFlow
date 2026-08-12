//
//  LoginViewController.swift
//  CoinFlow
//
//  Created by Ece Akcay on 12.08.2026.
//

import UIKit
import CryptoUI

final class LoginViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: LoginViewModel

    var onLoginSuccess: (() -> Void)?

    // MARK: - UI Components

    private let loginView = CryptoLoginView()

    // MARK: - Init

    init(viewModel: LoginViewModel) {
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
        configureLoginView()
        bindLoginView()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureLoginView()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = CryptoColors.appBackground

        view.addSubview(loginView)

        loginView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loginView.topAnchor.constraint(equalTo: view.topAnchor),
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureLoginView() {
        loginView.configure(
            CryptoLoginViewConfiguration(
                titleText: "CoinFlow",
                subtitleText: L10n.text(.loginSubtitle),
                usernameTitleText: L10n.text(.username).uppercased(),
                usernamePlaceholderText: "example",
                passwordTitleText: L10n.text(.password).uppercased(),
                passwordPlaceholderText: "••••••••",
                forgotPasswordText: L10n.text(.forgotPassword),
                signInButtonText: L10n.text(.signIn),
                dividerText: L10n.text(.or),
                faceIDButtonText: L10n.text(.signInWithFaceID),
                isForgotPasswordHidden: false,
                isFaceIDHidden: false
            )
        )
    }

    private func bindLoginView() {
        loginView.onSignInTapped = { [weak self] username, password in
            self?.viewModel.login(
                username: username,
                password: password
            )
        }

        loginView.onTextChanged = { [weak self] in
            self?.loginView.hideError()
        }

        loginView.onForgotPasswordTapped = { [weak self] in
            self?.loginView.showError(
                L10n.text(.passwordResetNotAvailable)
            )
        }

        loginView.onFaceIDTapped = { [weak self] in
            self?.loginView.showError(
                L10n.text(.signInBeforeFaceID)
            )
        }
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }

            DispatchQueue.main.async {
                switch state {
                case .idle:
                    break

                case .loading:
                    self.loginView.hideError()
                    self.loginView.setLoading(true)

                case .success:
                    self.loginView.setLoading(false)
                    self.onLoginSuccess?()

                case .failure(let message):
                    self.loginView.setLoading(false)
                    self.loginView.showError(message)
                }
            }
        }
    }
}
