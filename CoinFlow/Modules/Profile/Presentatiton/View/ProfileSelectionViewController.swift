//
//  ProfileSelectionViewController.swift
//  CoinFlow
//
//  Created by Ece Akcay on 7.08.2026.
//

import UIKit
import CryptoUI

final class ProfileSelectionViewController: UIViewController {
    
    // MARK: - Properties
    
    private let screenTitle: String
    private let options: [String]
    private var currentSelectedValue: String
    private let descriptionText: String?
    
    var onOptionSelected: ((String) -> Void)?
    
    // MARK: - UI Components
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(L10n.text(.done), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = CryptoFonts.body
        button.backgroundColor = CryptoColors.positive
        button.layer.cornerRadius = 18
        button.layer.borderWidth = 0
        button.layer.shadowOpacity = 0
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 18, bottom: 8, right: 18)
        button.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    
    init(title: String,options: [String],selectedValue: String,descriptionText: String? = nil) {
        self.screenTitle = title
        self.options = options
        self.currentSelectedValue = selectedValue
        self.descriptionText = descriptionText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = CryptoColors.appBackground
        applyTexts()
        
        setupNavigationBar()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTexts()
    }
    
    // MARK: - Language
    
    private func applyTexts() {
        title = screenTitle
        doneButton.setTitle(L10n.text(.done), for: .normal)
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        navigationController?.navigationBar.tintColor = UIColor.white
        
        doneButton.widthAnchor.constraint(equalToConstant: 78).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = CryptoColors.appBackground
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.sectionHeaderTopPadding = 0
        
        tableView.register(
            ProfileSelectionCell.self,
            forCellReuseIdentifier: ProfileSelectionCell.reuseIdentifier
        )
        
        tableView.contentInset = UIEdgeInsets(
            top: 16,
            left: 0,
            bottom: 32,
            right: 0
        )
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func didTapDone() {
        onOptionSelected?(currentSelectedValue)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ProfileSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ProfileSelectionCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let selectionCell = cell as? ProfileSelectionCell else {
            return cell
        }
        
        let option = options[indexPath.row]
        let isSelected = option == currentSelectedValue
        let isLastRow = indexPath.row == options.count - 1
        
        selectionCell.configure(
            title: option,
            isSelected: isSelected,
            hidesSeparator: isLastRow
        )
        
        return selectionCell
    }
    
    func tableView(_ tableView: UITableView,heightForRowAt indexPath: IndexPath) -> CGFloat {
        58
    }
    
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        currentSelectedValue = options[indexPath.row]
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView,titleForHeaderInSection section: Int) -> String? {
        return descriptionText
    }

    func tableView(_ tableView: UITableView,willDisplayHeaderView view: UIView,forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else {
            return
        }
        
        header.textLabel?.textColor = CryptoColors.secondaryText
        header.textLabel?.font = CryptoFonts.caption
    }
}
