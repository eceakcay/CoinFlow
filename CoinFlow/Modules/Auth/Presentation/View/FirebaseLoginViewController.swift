//
//  FirebaseLoginViewController.swift
//  CoinFlow
//
//  Created by Ece Akcay on 13.08.2026.
//

import UIKit
import CryptoUI

final class FirebaseLoginViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: FirebaseLoginViewModel

    var onLoginSuccess: (() -> Void)?
    var onCreateAccountTapped: (() -> Void)?

    // MARK: - UI Components

    private let loginView = CryptoLoginView()

    // MARK: - Init

    init(viewModel: FirebaseLoginViewModel) {
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
     //   title = L10n.text(.firebaseLoginTitle)

        loginView.configure(
            CryptoLoginViewConfiguration(
                titleText: L10n.text(.firebaseLoginTitle),
                subtitleText: L10n.text(.firebaseLoginSubtitle),
                usernameTitleText: L10n.text(.email).uppercased(),
                usernamePlaceholderText: L10n.text(.emailPlaceholder),
                passwordTitleText: L10n.text(.password).uppercased(),
                passwordPlaceholderText: "••••••••",
                forgotPasswordText: "",
                signInButtonText: L10n.text(.signIn),
                dividerText: "",
                faceIDButtonText: "",
                isForgotPasswordHidden: true,
                isFaceIDHidden: true,
                createAccountButtonText: L10n.text(.createAccount),
                isCreateAccountHidden: false,
                firebaseLoginButtonText: "",
                isFirebaseLoginHidden: true
            )
        )
    }

    private func bindLoginView() {
        loginView.onSignInTapped = { [weak self] email, password in
            self?.viewModel.login(
                email: email,
                password: password
            )
        }

        loginView.onCreateAccountTapped = { [weak self] _, _ in
            self?.onCreateAccountTapped?()
        }

        loginView.onTextChanged = { [weak self] in
            self?.loginView.hideError()
        }
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }

            DispatchQueue.main.async {
                switch state {
                case .idle:
                    self.loginView.setLoading(false)

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
