import Foundation
import WidgetKit

enum PortfolioWidgetSnapshotStore {
    static let appGroupIdentifier = "group.com.eceakcay.CoinFlow"
    static let widgetKind = "CoinFlowPortfolioWidget"

    private enum Keys {
        static let totalBalance = "widget.totalBalance"
        static let totalProfitLoss = "widget.totalProfitLoss"
        static let totalProfitLossPercentage = "widget.totalProfitLossPercentage"
        static let currencyCode = "widget.currencyCode"
        static let lastUpdated = "widget.lastUpdated"
        static let hasPortfolio = "widget.hasPortfolio"
    }

    static func save(summary: PortfolioSummary, currencyCode: String) {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else {
            return
        }

        defaults.set(summary.totalBalance, forKey: Keys.totalBalance)
        defaults.set(summary.totalProfitLoss, forKey: Keys.totalProfitLoss)
        defaults.set(summary.totalProfitLossPercentage, forKey: Keys.totalProfitLossPercentage)
        defaults.set(currencyCode, forKey: Keys.currencyCode)
        defaults.set(Date(), forKey: Keys.lastUpdated)
        defaults.set(!summary.holdings.isEmpty, forKey: Keys.hasPortfolio)

        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
    }
}
