import Foundation

enum CryptoAmountFormatter {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 8
        formatter.roundingMode = .halfUp
        return formatter
    }()

    static func string(from amount: Double) -> String {
        guard amount.isFinite else { return "0" }
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }

    static func string(from amount: Double, symbol: String) -> String {
        "\(string(from: amount)) \(symbol.uppercased())"
    }
}
