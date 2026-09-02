//
//  SceneDelegate.swift
//  CoinFlow
//
//  Created by Ece Akcay on 30.06.2026.
//

import UIKit
import CryptoUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    private var privacyShieldView: PrivacyShieldView?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = CryptoColors.appBackground
        let dependencyContainer = DependencyContainer()
        let appCoordinator = AppCoordinator(window: window, dependencyContainer: dependencyContainer)
        
        self.window = window
        self.appCoordinator = appCoordinator

        let launchAnimationViewController = LaunchAnimationViewController()
        launchAnimationViewController.onAnimationCompleted = { [weak appCoordinator] in
            appCoordinator?.start()
        }

        window.rootViewController = launchAnimationViewController
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        privacyShieldView?.removeFromSuperview()
        privacyShieldView = nil
    }

    func sceneWillResignActive(_ scene: UIScene) {
        showPrivacyShield()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }

    private func showPrivacyShield() {
        guard privacyShieldView == nil, let window else { return }

        let privacyShieldView = PrivacyShieldView(frame: window.bounds)
        privacyShieldView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(privacyShieldView)
        self.privacyShieldView = privacyShieldView
    }
}
