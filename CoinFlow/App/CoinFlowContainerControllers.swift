import UIKit

final class CoinFlowNavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override var childForStatusBarStyle: UIViewController? {
        nil
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        setNeedsStatusBarAppearanceUpdate()
    }
}

final class CoinFlowTabBarController: UITabBarController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override var childForStatusBarStyle: UIViewController? {
        nil
    }

    override var selectedViewController: UIViewController? {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
}
