//
//  PortfolioSummaryCalculator.swift
//  CoinFlow
//
//  Created by Ece Akcay on 31.07.2026.
//

import Foundation

//kullanıcının yaptığı alış satış işlemlerinden (PortfolioTransaction) portföyün güncel durumunu hesaplar
//hesaplama yapar sadece

final class PortfolioSummaryCalculator {
    
    //→ Alış-satışları işler→ Kalan coin miktarı bulur→ Kalan toplam maliyeti bulur.
    //Hesaplama tamamlanınca bu veriler PortfolioHolding modeline dönüştürülür.
    private func calculatePositions(from transactions: [PortfolioTransaction]) -> [String: PortfolioPosition] {
        let sortedTransactions = transactions.sorted { //tarihe göre işlemeleri sıralar
            $0.date < $1.date
        }
        
        //sözlük
        var positions: [String: PortfolioPosition] = [:]

        for transaction in sortedTransactions {
            
            //coin işleme alındıysa onu getir eğer alınmadıysa yeni oluştur
            var position = positions[transaction.coinId] ?? PortfolioPosition(
                coinName: transaction.coinName,
                symbol: transaction.symbol,
                amount: 0,
                totalCost: 0
            )

            switch transaction.type {
            case .buy:
                position.amount += transaction.amount
                position.totalCost += transaction.amount * transaction.pricePerCoin

            case .sell:
                guard position.amount > 0 else {
                    continue
                }

                let averageBuyPrice = position.totalCost / position.amount

                position.amount -= transaction.amount
                position.totalCost -= averageBuyPrice * transaction.amount
            }

            positions[transaction.coinId] = position
        }

        return positions
    }


    //kullanıcının yaptığı işlemler ve apiden güncel coinler-> parametre olarak
    
    //→ Ortalama alış fiyatını hesaplar → Güncel piyasa fiyatını ekler →
    // PortfolioHolding oluşturur → PortfolioSummary döndürür
    func calculate(transactions: [PortfolioTransaction], marketCoins: [CryptoCurrency]) -> PortfolioSummary {
        
        let positions = calculatePositions(from: transactions)//kaç coin var
        let marketCoinById = makeMarketCoinDictionary(from: marketCoins)//dizide tek tek dolaşmamak için

        let holdings = positions.compactMap { coinId, position -> PortfolioHolding? in
            guard position.amount > 0 else {
                return nil
            }

            let averageBuyPrice = position.totalCost / position.amount //ortalama alış fiyatı , api hata verirse
            let marketCoin = marketCoinById[coinId] //güncel market coini
            let currentPrice = marketCoin?.currentPrice ?? averageBuyPrice //CoinGecko fiyatı varsa onu kullan.Yoksa kullanıcının alış ortalamasını kullan.

            let imageURL: String?

            if let image = marketCoin?.imageURL, !image.isEmpty {
                imageURL = image
            } else {
                imageURL = nil
            }

            return PortfolioHolding(
                coinId: coinId,
                coinName: position.coinName,
                symbol: position.symbol,
                amount: position.amount,
                averageBuyPrice: averageBuyPrice,
                currentPrice: currentPrice,
                imageURL: imageURL
            )
        }

        return PortfolioSummary( //alfabetik sıralama
            holdings: holdings.sorted {
                $0.coinName < $1.coinName
            }
        )
    }

    //sözlüğe çevirme daha hızlı bulmak için
    private func makeMarketCoinDictionary(from marketCoins: [CryptoCurrency]) -> [String: CryptoCurrency] {
        var dictionary: [String: CryptoCurrency] = [:]

        for coin in marketCoins {
            dictionary[coin.id] = coin
        }

        return dictionary
    }
}

//hesaplama için kullanılan geçici bir model
private struct PortfolioPosition {
    let coinName: String
    let symbol: String
    var amount: Double
    var totalCost: Double
}
