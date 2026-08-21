//
//  ProfileSelectionCell.swift
//  CoinFlow
//
//  Created by Ece Akcay on 7.08.2026.
//

import UIKit
import CryptoUI

final class ProfileSelectionCell: UITableViewCell {
    
    static let reuseIdentifier = "ProfileSelectionCell"
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = CryptoFonts.body
        label.textColor = CryptoColors.primaryText
        return label
    }()
    
    private let checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = CryptoColors.positive
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = CryptoColors.cardBorder
        return view
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        titleLabel.textColor = CryptoColors.primaryText
        checkImageView.isHidden = true
        separatorView.isHidden = false
    }
    
    // MARK: - Configure
    
    func configure(
        title: String,
        isSelected: Bool,
        hidesSeparator: Bool
    ) {
        titleLabel.text = title
        
        titleLabel.textColor = isSelected
            ? CryptoColors.positive
            : CryptoColors.primaryText
        
        checkImageView.isHidden = !isSelected
        separatorView.isHidden = hidesSeparator
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = CryptoColors.cardBackground
        contentView.backgroundColor = CryptoColors.cardBackground
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkImageView)
        contentView.addSubview(separatorView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: checkImageView.leadingAnchor,
                constant: -12
            ),
            
            checkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            checkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkImageView.widthAnchor.constraint(equalToConstant: 22),
            checkImageView.heightAnchor.constraint(equalToConstant: 22),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
