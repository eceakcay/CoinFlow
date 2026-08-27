//
//  OnboardingViewController.swift
//  CoinFlow
//

import UIKit
import CryptoUI

final class OnboardingViewController: UIViewController {

    var onFinished: (() -> Void)?

    private let pages: [OnboardingPage]
    private var currentPageIndex = 0

    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(CryptoColors.primaryText.withAlphaComponent(0.78), for: .normal)
        return button
    }()

    private let imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = CryptoColors.positive.withAlphaComponent(0.14)
        view.layer.cornerRadius = 56
        return view
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = CryptoColors.positive
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: 52,
            weight: .medium
        )
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = CryptoColors.primaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = CryptoFonts.body
        label.textColor = CryptoColors.primaryText.withAlphaComponent(0.78)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let pageControl = UIPageControl()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = CryptoColors.positive
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.layer.cornerRadius = 14
        return button
    }()

    init(pages: [OnboardingPage]) {
        self.pages = pages
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        showPage(at: 0, animated: false)
        view.enableAdaptiveTypography()
    }

    private func setupUI() {
        view.backgroundColor = CryptoColors.appBackground

        [skipButton, imageContainerView, titleLabel, messageLabel, pageControl, nextButton]
            .forEach(view.addSubview)
        imageContainerView.addSubview(imageView)

        [skipButton, imageContainerView, imageView, titleLabel, messageLabel, pageControl, nextButton]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        pageControl.numberOfPages = pages.count
        pageControl.currentPageIndicatorTintColor = CryptoColors.positive
        pageControl.pageIndicatorTintColor = CryptoColors.secondaryText.withAlphaComponent(0.3)
        pageControl.isUserInteractionEnabled = false

        var constraints = [
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            imageContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -110),
            imageContainerView.widthAnchor.constraint(equalToConstant: 112),
            imageContainerView.heightAnchor.constraint(equalToConstant: 112),

            imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 64),
            imageView.heightAnchor.constraint(equalToConstant: 64),

            titleLabel.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 34),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 54),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -18)
        ]
        constraints += titleLabel.adaptiveHorizontalConstraints(in: view.safeAreaLayoutGuide, maximumWidth: 620, horizontalInset: 28)
        constraints += messageLabel.adaptiveHorizontalConstraints(in: view.safeAreaLayoutGuide, maximumWidth: 620, horizontalInset: 32)
        constraints += nextButton.adaptiveHorizontalConstraints(in: view.safeAreaLayoutGuide, maximumWidth: 560)
        NSLayoutConstraint.activate(constraints)
    }

    private func setupActions() {
        skipButton.addTarget(self, action: #selector(finishTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeRecognized(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRecognized(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }

    private func showPage(at index: Int, animated: Bool) {
        guard pages.indices.contains(index) else { return }

        currentPageIndex = index
        let page = pages[index]
        let updates = {
            self.imageView.image = UIImage(systemName: page.systemImageName)
            self.titleLabel.text = page.title
            self.messageLabel.text = page.message
            self.pageControl.currentPage = index
            self.skipButton.setTitle(L10n.text(.onboardingSkip), for: .normal)
            self.skipButton.isHidden = index == self.pages.count - 1
            let buttonTitle = index == self.pages.count - 1
                ? L10n.text(.onboardingGetStarted)
                : L10n.text(.onboardingNext)
            self.nextButton.setTitle(buttonTitle, for: .normal)
        }

        guard animated else {
            updates()
            return
        }

        UIView.transition(
            with: view,
            duration: 0.25,
            options: [.transitionCrossDissolve, .allowAnimatedContent],
            animations: updates
        )
    }

    @objc private func nextTapped() {
        let nextIndex = currentPageIndex + 1
        if pages.indices.contains(nextIndex) {
            showPage(at: nextIndex, animated: true)
        } else {
            onFinished?()
        }
    }

    @objc private func finishTapped() {
        onFinished?()
    }

    @objc private func swipeRecognized(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            showPage(at: min(currentPageIndex + 1, pages.count - 1), animated: true)
        } else {
            showPage(at: max(currentPageIndex - 1, 0), animated: true)
        }
    }
}
