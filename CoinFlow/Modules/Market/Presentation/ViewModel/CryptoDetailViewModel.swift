//
//  CryptoDetailViewModel.swift
//  CoinFlow
//
//  Created by Ece Akcay on 20.07.2026.
//

import Foundation

final class CryptoDetailViewModel {

    private let coin : CryptoCurrency
    
    private(set) var isFavorite = false
    
    init(coin: CryptoCurrency) {
        self.coin = coin
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
        return(coin.priceChangePercentage24h ?? 0) >= 0
    }
    
    var marketCapText: String {
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
        isFavorite.toggle()
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
