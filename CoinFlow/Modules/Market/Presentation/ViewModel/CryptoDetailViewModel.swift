//
//  CryptoDetailViewModel.swift
//  CoinFlow
//
//  Created by Ece Akcay on 20.07.2026.
//

import Foundation

final class CryptoDetailViewModel {

    let coin: CryptoCurrency

    init(coin: CryptoCurrency) {
        self.coin = coin
    }

    var titleText: String {
        return coin.name
    }

    var symbolText: String {
        return coin.symbol.uppercased()
    }

    var price: Double {
        return coin.currentPrice
    }

    var priceChangePercentage24h: Double? {
        return coin.priceChangePercentage24h
    }

    var marketCap: Double? {
        return coin.marketCap
    }
}
