//
//  PrivacyShieldView.swift
//  CoinFlow
//

import CryptoUI
import UIKit

final class PrivacyShieldView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }

    private func configureView() {
        let blurView = UIVisualEffectView(
            effect: UIBlurEffect(style: .systemChromeMaterialDark)
        )

        let darkOverlay = UIView()
        darkOverlay.backgroundColor = UIColor(
            red: 8 / 255,
            green: 9 / 255,
            blue: 11 / 255,
            alpha: 0.82
        )

        let glowView = UIView()
        glowView.backgroundColor = UIColor(
            red: 0.18,
            green: 0.78,
            blue: 0.47,
            alpha: 0.18
        )
        glowView.layer.cornerRadius = 58
        glowView.layer.shadowColor = UIColor(
            red: 0.18,
            green: 0.78,
            blue: 0.47,
            alpha: 1
        ).cgColor
        glowView.layer.shadowOpacity = 0.28
        glowView.layer.shadowRadius = 26
        glowView.layer.shadowOffset = .zero

        let logoImageView = UIImageView(image: UIImage(named: "LaunchLogo"))
        logoImageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = "CoinFlow"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor = CryptoColors.primaryText
        titleLabel.textAlignment = .center

        let privacyLabel = UILabel()
        privacyLabel.text = "Portfolio protected"
        privacyLabel.font = .systemFont(ofSize: 15, weight: .medium)
        privacyLabel.textColor = CryptoColors.secondaryText
        privacyLabel.textAlignment = .center

        let stackView = UIStackView(
            arrangedSubviews: [logoImageView, titleLabel, privacyLabel]
        )
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.setCustomSpacing(18, after: logoImageView)

        addSubview(blurView)
        blurView.contentView.addSubview(darkOverlay)
        blurView.contentView.addSubview(glowView)
        blurView.contentView.addSubview(stackView)

        blurView.translatesAutoresizingMaskIntoConstraints = false
        darkOverlay.translatesAutoresizingMaskIntoConstraints = false
        glowView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            darkOverlay.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
            darkOverlay.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            darkOverlay.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
            darkOverlay.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor),

            stackView.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor),

            logoImageView.widthAnchor.constraint(equalToConstant: 116),
            logoImageView.heightAnchor.constraint(equalToConstant: 116),

            glowView.centerXAnchor.constraint(equalTo: logoImageView.centerXAnchor),
            glowView.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor),
            glowView.widthAnchor.constraint(equalToConstant: 116),
            glowView.heightAnchor.constraint(equalToConstant: 116)
        ])
    }
}
