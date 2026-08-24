import SwiftUI
import WidgetKit

private enum WidgetConstants {
    static let appGroupIdentifier = "group.com.eceakcay.CoinFlow"
    static let kind = "CoinFlowPortfolioWidget"
}

private struct PortfolioWidgetEntry: TimelineEntry {
    let date: Date
    let totalBalance: Double
    let totalProfitLoss: Double
    let totalProfitLossPercentage: Double
    let currencyCode: String
    let lastUpdated: Date?
    let hasPortfolio: Bool
}

private struct PortfolioWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PortfolioWidgetEntry {
        PortfolioWidgetEntry(
            date: Date(),
            totalBalance: 24_680.42,
            totalProfitLoss: 1_284.16,
            totalProfitLossPercentage: 5.49,
            currencyCode: "USD",
            lastUpdated: Date(),
            hasPortfolio: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PortfolioWidgetEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PortfolioWidgetEntry>) -> Void) {
        let entry = currentEntry()
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1_800)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func currentEntry() -> PortfolioWidgetEntry {
        let defaults = UserDefaults(suiteName: WidgetConstants.appGroupIdentifier)

        return PortfolioWidgetEntry(
            date: Date(),
            totalBalance: defaults?.double(forKey: "widget.totalBalance") ?? 0,
            totalProfitLoss: defaults?.double(forKey: "widget.totalProfitLoss") ?? 0,
            totalProfitLossPercentage: defaults?.double(forKey: "widget.totalProfitLossPercentage") ?? 0,
            currencyCode: defaults?.string(forKey: "widget.currencyCode") ?? "USD",
            lastUpdated: defaults?.object(forKey: "widget.lastUpdated") as? Date,
            hasPortfolio: defaults?.bool(forKey: "widget.hasPortfolio") ?? false
        )
    }
}

private struct CoinFlowPortfolioWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: PortfolioWidgetEntry

    private var isTurkish: Bool {
        Locale.current.language.languageCode?.identifier == "tr"
    }

    private var profitColor: Color {
        entry.totalProfitLoss >= 0 ? Color(red: 0.18, green: 0.78, blue: 0.47) : Color(red: 0.95, green: 0.31, blue: 0.35)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: family == .systemSmall ? 9 : 12) {
            header

            if entry.hasPortfolio {
                portfolioContent
            } else {
                emptyContent
            }

            Spacer(minLength: 0)
            updatedText
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color(red: 0.055, green: 0.075, blue: 0.12), Color(red: 0.08, green: 0.12, blue: 0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var header: some View {
        HStack(spacing: 7) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.caption.bold())
                .foregroundStyle(Color(red: 0.18, green: 0.78, blue: 0.47))

            Text("CoinFlow")
                .font(.caption.bold())
                .foregroundStyle(.white)

            Spacer()
        }
    }

    private var portfolioContent: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(isTurkish ? "Toplam Portföy" : "Total Portfolio")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.62))

            Text(currency(entry.totalBalance))
                .font(family == .systemSmall ? .title3.bold() : .title2.bold())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.65)

            HStack(spacing: 5) {
                Image(systemName: entry.totalProfitLoss >= 0 ? "arrow.up.right" : "arrow.down.right")
                Text(currency(entry.totalProfitLoss))
                Text("(\(signedPercentage(entry.totalProfitLossPercentage)))")
            }
            .font(.caption.bold())
            .foregroundStyle(profitColor)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(profitAccessibilityLabel)
        }
    }

    private var emptyContent: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(isTurkish ? "Portföyün hazır" : "Your portfolio awaits")
                .font(.headline)
                .foregroundStyle(.white)

            Text(isTurkish ? "İlk işlemini CoinFlow'da ekle." : "Add your first transaction in CoinFlow.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.62))
                .lineLimit(2)
        }
    }

    private var updatedText: some View {
        Group {
            if let lastUpdated = entry.lastUpdated {
                Text(lastUpdated, style: .relative)
            } else {
                Text(isTurkish ? "Uygulamayı açarak güncelle" : "Open the app to update")
            }
        }
        .font(.caption2)
        .foregroundStyle(.white.opacity(0.45))
        .lineLimit(1)
    }

    private var profitAccessibilityLabel: String {
        let direction: String
        if isTurkish {
            direction = entry.totalProfitLoss >= 0 ? "Kâr" : "Zarar"
        } else {
            direction = entry.totalProfitLoss >= 0 ? "Profit" : "Loss"
        }
        return "\(direction), \(currency(abs(entry.totalProfitLoss))), \(abs(entry.totalProfitLossPercentage).formatted(.number.precision(.fractionLength(2)))) percent"
    }

    private func currency(_ value: Double) -> String {
        value.formatted(
            .currency(code: entry.currencyCode)
                .precision(.fractionLength(abs(value) < 1 ? 4 : 2))
        )
    }

    private func signedPercentage(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : "−"
        return "\(sign)\(abs(value).formatted(.number.precision(.fractionLength(2))))%"
    }
}

struct CoinFlowPortfolioWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: WidgetConstants.kind,
            provider: PortfolioWidgetProvider()
        ) { entry in
            CoinFlowPortfolioWidgetView(entry: entry)
        }
        .configurationDisplayName("CoinFlow Portfolio")
        .description("View your portfolio value and total profit or loss.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    CoinFlowPortfolioWidget()
} timeline: {
    PortfolioWidgetEntry(
        date: .now,
        totalBalance: 24_680.42,
        totalProfitLoss: 1_284.16,
        totalProfitLossPercentage: 5.49,
        currencyCode: "USD",
        lastUpdated: .now,
        hasPortfolio: true
    )
}
