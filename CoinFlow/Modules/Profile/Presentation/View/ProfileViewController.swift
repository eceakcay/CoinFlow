//
//  ProfileViewController.swift
//  CoinFlow
//
//  Created by Ece Akcay on 9.07.2026.
//

import UIKit
import CryptoUI

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: ProfileViewModel
    
    var onCurrencyTapped: (() -> Void)?
    var onLanguageTapped: (() -> Void)?
    var onLogoutTapped: (() -> Void)?
    var onAccountDeleted: (() -> Void)?
    
    // MARK: - UI Components
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    private let headerView = UIView()
    
    private let avatarView: UIView = {
        let view = UIView()
        view.backgroundColor = CryptoColors.positive.withAlphaComponent(0.16)
        view.layer.cornerRadius = 34
        return view
    }()
    
    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.text = nil
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = CryptoColors.positive
        label.textAlignment = .center
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = nil
        label.font = CryptoFonts.title
        label.textColor = CryptoColors.primaryText
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Crypto Portfolio Tracker"
        label.font = CryptoFonts.caption
        label.textColor = CryptoColors.secondaryText
        label.textAlignment = .center
        return label
    }()
    
    private let loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        view.isHidden = true
        return view
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        return indicator
    }()

    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = CryptoFonts.body
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Init
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTexts()
        
        view.backgroundColor = CryptoColors.appBackground
        
        setupNavigationBar()
        setupTableView()
        setupLoadingView()
        bindViewModel()
        
        viewModel.viewDidLoad()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = CryptoColors.appBackground
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(
            CryptoProfileOptionCell.self,
            forCellReuseIdentifier: CryptoProfileOptionCell.reuseIdentifier
        )
        
        tableView.tableHeaderView = makeHeaderView()
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupLoadingView() {

        view.addSubview(loadingView)

        loadingView.addSubview(loadingIndicator)
        loadingView.addSubview(loadingLabel)

        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(
                equalTo: loadingView.centerXAnchor
            ),

            loadingIndicator.centerYAnchor.constraint(
                equalTo: loadingView.centerYAnchor,
                constant: -20
            ),

            loadingLabel.topAnchor.constraint(
                equalTo: loadingIndicator.bottomAnchor,
                constant: 12
            ),

            loadingLabel.centerXAnchor.constraint(
                equalTo: loadingView.centerXAnchor
            )
        ])
    }
    
    private func makeHeaderView() -> UIView {
        headerView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: 170
        )
        
        headerView.backgroundColor = CryptoColors.appBackground
        
        headerView.addSubview(avatarView)
        avatarView.addSubview(avatarLabel)
        headerView.addSubview(nameLabel)
        headerView.addSubview(subtitleLabel)
        
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
            avatarView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 68),
            avatarView.heightAnchor.constraint(equalToConstant: 68),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20)
        ])
        
        return headerView
    }
    
    // MARK: - Binding

    private func bindViewModel() {

        viewModel.onStateChange = { [weak self] state in

            guard let self else { return }

            DispatchQueue.main.async {

                switch state {
                case .idle:
                    self.hideDeleteAccountLoading()
                    
                case .loading:
                    self.showDeleteAccountLoading()
                    
                case .success:
                    self.hideDeleteAccountLoading()
                    self.applyTexts()
                    self.tableView.reloadData()

                case .accountDeleted:
                    self.hideDeleteAccountLoading()
                    self.onAccountDeleted?()

                case .failure(let message):
                    self.hideDeleteAccountLoading()
                    self.showAlert(
                        title: L10n.text(.deleteAccountFailed),
                        message: message
                    )
                }
            }
        }
    }
    
    private func showAppInfo() {
        let alert = UIAlertController(
            title: "CoinFlow",
            message: L10n.text(.appInfoMessage),
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: L10n.text(.ok),
                style: .default
            )
        )
        
        present(alert, animated: true)
    }
    
    // MARK: - Pop up

    private func showResetPortfolioConfirmation() {
        let alert = UIAlertController(
            title: L10n.text(.resetPortfolioTitle),
            message: L10n.text(.resetPortfolioMessage),
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: L10n.text(.cancel),
                style: .cancel
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: L10n.text(.reset),
                style: .destructive
            ) { [weak self] _ in
                
                guard let self else { return }
                
                do {
                    try self.viewModel.resetPortfolioData()
                    self.showAlert(
                        title: L10n.text(.portfolioReset),
                        message: L10n.text(.portfolioResetMessage)
                    )
                } catch {
                    self.showAlert(
                        title: L10n.text(.resetFailed),
                        message: error.localizedDescription
                    )
                }
            }
        )
        
        present(alert, animated: true)
    }
    
    private func showDeleteAccountLoading() {

        loadingLabel.text =
            L10n.text(.deletingAccount)

        loadingView.isHidden = false
        loadingIndicator.startAnimating()
    }

    private func hideDeleteAccountLoading() {

        loadingIndicator.stopAnimating()
        loadingView.isHidden = true
    }
    
    private func showDeleteAccountConfirmation() {

        let alert = UIAlertController(
            title: L10n.text(.deleteAccount),
            message: L10n.text(.deleteAccountConfirmationMessage),
            preferredStyle: .alert
        )

        alert.addTextField { textField in

            textField.placeholder = L10n.text(.passwordPlaceholder)
            textField.isSecureTextEntry = true
            textField.textContentType = .password
        }

        alert.addAction(
            UIAlertAction(
                title: L10n.text(.cancel),
                style: .cancel
            )
        )

        alert.addAction(
            UIAlertAction(
                title: L10n.text(.deleteAccount),
                style: .destructive
            ) { [weak self, weak alert] _ in

                guard let self else {
                    return
                }

                let password =
                    alert?.textFields?.first?.text ?? ""

                self.viewModel.deleteAccount(
                    password: password
                )
            }
        )

        present(alert,animated: true)
    }
    
    private func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: L10n.text(.logoutTitle),
            message: L10n.text(.logoutMessage),
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: L10n.text(.cancel),
                style: .cancel
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: L10n.text(.logout),
                style: .destructive
            ) { [weak self] _ in
                guard let self else { return }
                
                do {
                    try self.viewModel.logout()
                    self.onLogoutTapped?()
                } catch {
                    self.showAlert(
                        title: L10n.text(.logoutFailed),
                        message: error.localizedDescription
                    )
                }
            }
        )
        
        present(alert, animated: true)
    }
    
    // MARK: - Helpers
    
    private func makeAccessoryType(from accessoryType: ProfileAccessoryType) -> CryptoProfileAccessoryType {
        switch accessoryType {
        case .chevron:
            return .chevron
            
        case .toggle(let isOn):
            return .toggle(isOn: isOn)
            
        case .none:
            return .none
        }
    }
    
    private func applyTexts() {
        title = L10n.text(.profile)
        subtitleLabel.text = L10n.text(.appSubtitle)

        nameLabel.text = viewModel.userDisplayName
        avatarLabel.text = viewModel.userInitialText
    }
}
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
        
        func numberOfSections(in tableView: UITableView) -> Int {
            viewModel.numberOfSections()
        }
        
        func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
            viewModel.numberOfRows(in: section)
        }
        
        func tableView(_ tableView: UITableView,titleForHeaderInSection section: Int) -> String? {
            viewModel.sectionTitle(at: section)
        }
        
        func tableView(_ tableView: UITableView,willDisplayHeaderView view: UIView,forSection section: Int) {
            guard let header = view as? UITableViewHeaderFooterView else {
                return
            }
            
            header.textLabel?.textColor = CryptoColors.secondaryText
            header.textLabel?.font = CryptoFonts.caption
        }
        
        func tableView(_ tableView: UITableView,heightForFooterInSection section: Int) -> CGFloat {
            12
        }
        
        func tableView(_ tableView: UITableView,viewForFooterInSection section: Int) -> UIView? {
            let view = UIView()
            view.backgroundColor = CryptoColors.appBackground
            return view
        }
        
        func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CryptoProfileOptionCell.reuseIdentifier,
                for: indexPath
            )
            
            guard let profileCell = cell as? CryptoProfileOptionCell,
                  let item = viewModel.item(at: indexPath) else {
                return cell
            }
            
            let configuration = CryptoProfileOptionCellConfiguration(
                title: item.title,
                subtitle: item.subtitle,
                systemImageName: item.systemImageName,
                accessoryType: makeAccessoryType(from: item.accessoryType),
                isDestructive: item.isDestructive
            )
            
            profileCell.configure(with: configuration)
            
            profileCell.onToggleChanged = { [weak self] isOn in
                guard item.type == .biometric else { return }
                self?.viewModel.setBiometricEnabled(isOn)
            }
            
            return profileCell
        }
        
        func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
                
                guard let item = viewModel.item(at: indexPath) else {
                    return
                }
                
            switch item.type {

            case .currency:
                onCurrencyTapped?()

            case .language:
                onLanguageTapped?()

            case .biometric:
                break

            case .appInfo:
                showAppInfo()

            case .resetPortfolio:
                showResetPortfolioConfirmation()

            case .deleteAccount:
                showDeleteAccountConfirmation()

            case .logout:
                showLogoutConfirmation()
            }
        }
    }
