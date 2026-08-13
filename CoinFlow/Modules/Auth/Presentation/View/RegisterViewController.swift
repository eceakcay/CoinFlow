//
//  RegisterViewController.swift
//  CoinFlow
//
//  Created by Ece Akcay on 13.08.2026.
//

import UIKit
import CryptoUI

final class RegisterViewController: UIViewController {

    private let viewModel: RegisterViewModel

    var onRegisterSuccess: (() -> Void)?

    private let registerView = CryptoLoginView()

    init(viewModel: RegisterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        configureRegisterView()
        bindRegisterView()
        bindViewModel()
    }

    private func setupUI() {
        view.backgroundColor = CryptoColors.appBackground

        view.addSubview(registerView)

        registerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            registerView.topAnchor.constraint(equalTo: view.topAnchor),
            registerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            registerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            registerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureRegisterView() {
        title = L10n.text(.createAccount)

        registerView.configure(
            CryptoLoginViewConfiguration(
                titleText: L10n.text(.createAccount),
                subtitleText: L10n.text(.loginSubtitle),
                usernameTitleText: L10n.text(.email).uppercased(),
                usernamePlaceholderText: "email@example.com",
                passwordTitleText: L10n.text(.password).uppercased(),
                passwordPlaceholderText: "••••••••",
                forgotPasswordText: "",
                signInButtonText: L10n.text(.createAccount),
                dividerText: "",
                faceIDButtonText: "",
                isForgotPasswordHidden: true,
                isFaceIDHidden: true,
                createAccountButtonText: "",
                isCreateAccountHidden: true,
                firebaseLoginButtonText: "",
                isFirebaseLoginHidden: true
            )
        )
    }

    private func bindRegisterView() {
        registerView.onSignInTapped = { [weak self] email, password in
            self?.viewModel.register(
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
}
