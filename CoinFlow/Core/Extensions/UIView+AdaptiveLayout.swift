import UIKit
import ObjectiveC

private var adaptiveTypographyKey: UInt8 = 0

extension UIView {
    func adaptiveHorizontalConstraints(
        in container: UILayoutGuide,
        maximumWidth: CGFloat = 760,
        horizontalInset: CGFloat = 24
    ) -> [NSLayoutConstraint] {
        let preferredWidth = widthAnchor.constraint(
            equalTo: container.widthAnchor,
            constant: -(horizontalInset * 2)
        )
        preferredWidth.priority = .defaultHigh

        return [
            centerXAnchor.constraint(equalTo: container.centerXAnchor),
            leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: horizontalInset),
            trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -horizontalInset),
            widthAnchor.constraint(lessThanOrEqualToConstant: maximumWidth),
            preferredWidth
        ]
    }

    func enableAdaptiveTypography() {
        // CryptoUI's compact-width components have an established iPhone
        // layout. Keep their original metrics intact and apply the additional
        // scaling pass only to regular-width presentations.
        guard traitCollection.horizontalSizeClass == .regular else { return }
        guard objc_getAssociatedObject(self, &adaptiveTypographyKey) == nil else { return }
        objc_setAssociatedObject(self, &adaptiveTypographyKey, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        applyAdaptiveTypographyRecursively()
    }

    private func applyAdaptiveTypographyRecursively() {
        if let label = self as? UILabel {
            let baseFont = label.font.withSize(max(label.font.pointSize, 13))
            label.font = UIFontMetrics(forTextStyle: textStyle(for: baseFont.pointSize))
                .scaledFont(for: baseFont)
            label.adjustsFontForContentSizeCategory = true
            if label.numberOfLines != 1 {
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
            }
        } else if let textField = self as? UITextField, let font = textField.font {
            textField.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font.withSize(max(font.pointSize, 17)))
            textField.adjustsFontForContentSizeCategory = true
        } else if let textView = self as? UITextView, let font = textView.font {
            textView.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font.withSize(max(font.pointSize, 17)))
            textView.adjustsFontForContentSizeCategory = true
        } else if let button = self as? UIButton, let titleLabel = button.titleLabel {
            let baseFont = titleLabel.font.withSize(max(titleLabel.font.pointSize, 15))
            titleLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont)
            titleLabel.adjustsFontForContentSizeCategory = true
            titleLabel.adjustsFontSizeToFitWidth = false
            titleLabel.lineBreakMode = .byWordWrapping
            titleLabel.textAlignment = .center
        }

        subviews.forEach { $0.applyAdaptiveTypographyRecursively() }
    }

    private func textStyle(for pointSize: CGFloat) -> UIFont.TextStyle {
        switch pointSize {
        case 22...: return .title2
        case 17...: return .body
        case 15...: return .subheadline
        default: return .footnote
        }
    }
}
