//
//  OnboardingCoordinator.swift
//  CoinFlow
//

import UIKit

final class OnboardingCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    var navigationController = UINavigationController()
    var onFinished: (() -> Void)?

    func start() {
        let pages = [
            OnboardingPage(
                systemImageName: "chart.line.uptrend.xyaxis",
                title: L10n.text(.onboardingMarketTitle),
                message: L10n.text(.onboardingMarketMessage)
            ),
            OnboardingPage(
                systemImageName: "chart.pie.fill",
                title: L10n.text(.onboardingPortfolioTitle),
                message: L10n.text(.onboardingPortfolioMessage)
            ),
            OnboardingPage(
                systemImageName: "person.crop.circle.badge.checkmark",
                title: L10n.text(.onboardingGuestTitle),
                message: L10n.text(.onboardingGuestMessage)
            )
        ]

        let viewController = OnboardingViewController(pages: pages)
        viewController.onFinished = { [weak self] in
            self?.onFinished?()
        }
        navigationController.setViewControllers([viewController], animated: false)
        navigationController.setNavigationBarHidden(true, animated: false)
    }
}
