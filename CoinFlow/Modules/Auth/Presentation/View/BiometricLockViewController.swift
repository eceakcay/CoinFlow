import UIKit
import CryptoUI

final class BiometricLockViewController: UIViewController {
    private let viewModel: FirebaseLoginViewModel
    private var didRequestAuthentication = false

    var onUnlock: (() -> Void)?
    var onUsePassword: (() -> Void)?

    private let iconView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "faceid"))
        view.tintColor = CryptoColors.primaryText
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "CoinFlow"
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textAlignment = .center
        label.textColor = CryptoColors.primaryText
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.text(.faceIDReason)
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = CryptoColors.secondaryText
        return label
    }()

    private lazy var unlockButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = L10n.text(.signInWithFaceID)
        configuration.image = UIImage(systemName: "faceid")
        configuration.imagePadding = 10
        configuration.cornerStyle = .large
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(requestAuthentication), for: .touchUpInside)
        return button
    }()

    private lazy var passwordButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = L10n.text(.signIn)
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(usePassword), for: .touchUpInside)
        return button
    }()

    init(viewModel: FirebaseLoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = CryptoColors.appBackground
        bindViewModel()
        setupLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didRequestAuthentication else { return }
        didRequestAuthentication = true
        requestAuthentication()
    }

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [
            iconView, titleLabel, messageLabel, unlockButton, passwordButton
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 18
        stack.setCustomSpacing(28, after: messageLabel)
        iconView.heightAnchor.constraint(equalToConstant: 74).isActive = true
        unlockButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32)
        ])
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard case .success = state else { return }
            DispatchQueue.main.async { self?.onUnlock?() }
        }
    }

    @objc private func requestAuthentication() {
        viewModel.loginWithBiometrics(reason: L10n.text(.faceIDReason))
    }

    @objc private func usePassword() {
        onUsePassword?()
    }
}
