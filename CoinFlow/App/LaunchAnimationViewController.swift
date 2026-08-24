import UIKit

final class LaunchAnimationViewController: UIViewController {
    var onAnimationCompleted: (() -> Void)?

    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "LaunchLogo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let glowView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.18, green: 0.78, blue: 0.47, alpha: 0.22)
        view.layer.cornerRadius = 70
        view.layer.shadowColor = UIColor(red: 0.18, green: 0.78, blue: 0.47, alpha: 1).cgColor
        view.layer.shadowOpacity = 0.35
        view.layer.shadowRadius = 28
        view.layer.shadowOffset = .zero
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(
            red: 8 / 255,
            green: 9 / 255,
            blue: 11 / 255,
            alpha: 1
        )

        view.addSubview(glowView)
        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            glowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            glowView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            glowView.widthAnchor.constraint(equalToConstant: 140),
            glowView.heightAnchor.constraint(equalToConstant: 140),

            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 140),
            logoImageView.heightAnchor.constraint(equalToConstant: 140)
        ])

        glowView.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playAnimation()
    }

    private func playAnimation() {
        guard !UIAccessibility.isReduceMotionEnabled else {
            UIView.animate(withDuration: 0.2, delay: 0.25, options: .curveEaseOut) {
                self.view.alpha = 0
            } completion: { [weak self] _ in
                self?.finishAnimation()
            }
            return
        }

        UIView.animate(
            withDuration: 0.5,
            delay: 0.08,
            usingSpringWithDamping: 0.58,
            initialSpringVelocity: 0.4,
            options: [.curveEaseOut]
        ) {
            self.logoImageView.transform = CGAffineTransform(scaleX: 1.12, y: 1.12)
            self.glowView.transform = CGAffineTransform(scaleX: 1.22, y: 1.22)
            self.glowView.alpha = 1
        } completion: { _ in
            UIView.animate(
                withDuration: 0.42,
                delay: 0.05,
                options: [.curveEaseInOut]
            ) {
                self.logoImageView.transform = .identity
                self.glowView.transform = .identity
                self.glowView.alpha = 0.45
            } completion: { _ in
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0.08,
                    options: [.curveEaseIn]
                ) {
                    self.logoImageView.transform = CGAffineTransform(scaleX: 1.18, y: 1.18)
                    self.logoImageView.alpha = 0
                    self.glowView.transform = CGAffineTransform(scaleX: 1.55, y: 1.55)
                    self.glowView.alpha = 0
                    self.view.alpha = 0
                } completion: { [weak self] _ in
                    self?.finishAnimation()
                }
            }
        }
    }

    private func finishAnimation() {
        let completion = onAnimationCompleted
        onAnimationCompleted = nil
        completion?()
    }
}
