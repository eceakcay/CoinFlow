//
//  CryptoDetailViewModel.swift
//  CoinFlow
//
//  Created by Ece Akcay on 20.07.2026.
//

import Foundation

final class CryptoDetailViewModel {
    
    // MARK: - Properties
    
    private let coin: CryptoCurrency
    private let isFavoriteCoinUseCase: IsFavoriteCoinUseCase
    private let toggleFavoriteCoinUseCase: ToggleFavoriteCoinUseCase
    private let fetchCoinChartUseCase: FetchCoinChartUseCase
    private let userDefaultsManager: UserDefaultsManager
    
    private(set) var isFavorite = false
    private(set) var chartPoints: [CoinChartPoint] = []
    private(set) var selectedChartRange: ChartTimeRange = .sevenDays
    
    // Rate limit için
    private var chartTask: Task<Void, Never>?
    private var chartCache: [String: [CoinChartPoint]] = [:]
    
    var onFavoriteChange: ((Bool) -> Void)?
    var onChartDataChange: (([CoinChartPoint]) -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Init
    
    init(
        coin: CryptoCurrency,
        isFavoriteCoinUseCase: IsFavoriteCoinUseCase,
        toggleFavoriteCoinUseCase: ToggleFavoriteCoinUseCase,
        fetchCoinChartUseCase: FetchCoinChartUseCase,
        userDefaultsManager: UserDefaultsManager
    ) {
        self.coin = coin
        self.isFavoriteCoinUseCase = isFavoriteCoinUseCase
        self.toggleFavoriteCoinUseCase = toggleFavoriteCoinUseCase
        self.fetchCoinChartUseCase = fetchCoinChartUseCase
        self.userDefaultsManager = userDefaultsManager
    }
    
    // MARK: - Lifecycle
    
    func viewDidLoad() {
        isFavorite = isFavoriteCoinUseCase.execute(coinId: coin.id)
        onFavoriteChange?(isFavorite)
        
        fetchChart(range: selectedChartRange)
    }
    
    // MARK: - Chart
    
    private func fetchChart(range: ChartTimeRange) {
        let vsCurrency = userDefaultsManager.appCurrency.apiValue
        let cacheKey = "\(vsCurrency)-\(range.rawValue)"
        
        if let cachedPoints = chartCache[cacheKey] {
            chartPoints = cachedPoints
            onChartDataChange?(cachedPoints)
            return
        }
        
        chartTask?.cancel()
        
        chartTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                let points = try await self.fetchCoinChartUseCase.execute(
                    coinId: self.coin.id,
                    days: range.days,
                    vsCurrency: vsCurrency
                )
                
                guard !Task.isCancelled else {
                    return
                }
                
                await MainActor.run {
                    self.chartCache[cacheKey] = points
                    self.chartPoints = points
                    self.onChartDataChange?(points)
                }
            } catch {
                guard !Task.isCancelled else {
                    return
                }
                
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
    
    // MARK: - Display Texts
    
    var titleText: String {
        coin.name
    }
    
    var symbolText: String {
        coin.symbol.uppercased()
    }
    
    var priceText: String {
        formatCurrency(coin.currentPrice)
    }
    
    var changeText: String {
        guard let value = coin.priceChangePercentage24h else {
            return "N/A"
        }
        
        return String(format: "%.2f%%", value)
    }
    
    var isChangePositive: Bool {
        (coin.priceChangePercentage24h ?? 0) >= 0
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
        isFavorite ? "heart.fill" : "heart"
    }
    
    // MARK: - Actions
    
    func toggleFavorite() {
        isFavorite = toggleFavoriteCoinUseCase.execute(coinId: coin.id)
        onFavoriteChange?(isFavorite)
    }
    
    // MARK: - Private Methods
    
    private func formatCurrency(_ value: Double) -> String {
        let currency = userDefaultsManager.appCurrency
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        formatter.locale = Locale(identifier: currency.localeIdentifier)
        
        if value >= 1_000_000 {
            formatter.maximumFractionDigits = 0
        } else if value < 1 {
            formatter.maximumFractionDigits = 6
        } else {
            formatter.maximumFractionDigits = 2
        }
        
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
