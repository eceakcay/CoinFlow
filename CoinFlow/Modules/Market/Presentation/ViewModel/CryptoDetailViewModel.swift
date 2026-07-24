//
//  CryptoDetailViewModel.swift
//  CoinFlow
//
//  Created by Ece Akcay on 20.07.2026.
//

import Foundation

final class CryptoDetailViewModel {

    private let coin: CryptoCurrency
    private let isFavoriteCoinUseCase: IsFavoriteCoinUseCase
    private let toggleFavoriteCoinUseCase: ToggleFavoriteCoinUseCase
    private let fetchCoinChartUseCase : FetchCoinChartUseCase
    
    private(set) var isFavorite = false
    private(set) var chartPoints: [CoinChartPoint] = []
    private(set) var selectedChartRange: ChartTimeRange = .sevenDays
    
    //Rate limit için
    private var chartTask: Task<Void, Never>?
    private var chartCache: [ChartTimeRange: [CoinChartPoint]] = [:]

    var onFavoriteChange: ((Bool) -> Void)?
    var onChartDataChange: (([CoinChartPoint]) -> Void)?
    var onError: ((String) -> Void)?

    init(coin: CryptoCurrency, isFavoriteCoinUseCase: IsFavoriteCoinUseCase, toggleFavoriteCoinUseCase: ToggleFavoriteCoinUseCase, fetchCoinChartUseCase: FetchCoinChartUseCase) {
        self.coin = coin
        self.isFavoriteCoinUseCase = isFavoriteCoinUseCase
        self.toggleFavoriteCoinUseCase = toggleFavoriteCoinUseCase
        self.fetchCoinChartUseCase = fetchCoinChartUseCase
    }

    func viewDidLoad() {
        isFavorite = isFavoriteCoinUseCase.execute(coinId: coin.id)
        onFavoriteChange?(isFavorite)
        
        fetchChart(range: selectedChartRange)
    }
    
   private func fetchChart(range: ChartTimeRange) {
       
       if let cachedPoints = chartCache[range] {
           chartPoints = cachedPoints
           onChartDataChange?(cachedPoints)
           return
       }
       
       chartTask?.cancel()
            
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let points = try await self.fetchCoinChartUseCase.execute(coinId: self.coin.id, days: range.days)
                
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    self.chartCache[range] = points
                    self.chartPoints = points
                    self.onChartDataChange?(points)
                }
            } catch {
                
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    func selectChartRange(at index: Int) {
        guard let range = ChartTimeRange(rawValue: index) else {
            return
        }

        guard selectedChartRange != range || chartPoints.isEmpty else {
            return
        }
        
        selectedChartRange = range
        fetchChart(range: range)
    }

    var titleText: String {
        return coin.name
    }

    var symbolText: String {
        return coin.symbol.uppercased()
    }

    var priceText: String {
        return formatCurrency(coin.currentPrice)
    }

    var changeText: String {
        guard let value = coin.priceChangePercentage24h else {
            return "N/A"
        }

        return String(format: "%.2f%%", value)
    }

    var isChangePositive: Bool {
        return (coin.priceChangePercentage24h ?? 0) >= 0
    }

    var marketCapText: String {
        guard let marketCap = coin.marketCap else {
            return "N/A"
        }

        return formatCurrency(marketCap)
    }

    var volumeText: String {
        guard let volume = coin.totalVolume else {
            return "N/A"
        }

        return formatCurrency(volume)
    }

    var rankText: String {
        guard let rank = coin.marketCapRank else {
            return "N/A"
        }

        return "#\(rank)"
    }

    var favoriteIconName: String {
        return isFavorite ? "heart.fill" : "heart"
    }

    func toggleFavorite() {
        isFavorite = toggleFavoriteCoinUseCase.execute(coinId: coin.id)
        onFavoriteChange?(isFavorite)
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"

        if value >= 1_000_000 {
            formatter.maximumFractionDigits = 0
        } else if value < 1 {
            formatter.maximumFractionDigits = 6
        } else {
            formatter.maximumFractionDigits = 2
        }

        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
    
}
