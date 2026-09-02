//
//  PortfolioSummary.swift
//  CoinFlow
//
//  Created by Ece Akcay on 24.07.2026.
//

import Foundation

//Bütün PortfolioHolding nesnelerini bir arada tutar ve toplam portföy değerlerini hesaplar.
struct PortfolioSummary {
    let holdings: [PortfolioHolding]

    var hasCompleteMarketPrices: Bool {
        holdings.allSatisfy(\.isCurrentPriceAvailable)
    }

    var hasCompleteCostBasis: Bool {
        holdings.allSatisfy(\.isCostBasisAvailable)
    }

    var hasCompleteProfitLossData: Bool {
        hasCompleteMarketPrices && hasCompleteCostBasis
    }
    
    //toplam bakiye
    var totalBalance : Double {
        return holdings.reduce(0) { result, holding in
            result + holding.currentValue
        }
    }
    
    //yatırılan sermaye
    var investedCapital : Double {
        return holdings.reduce(0) { result, holding in
            result + holding.investedValue
        }
    }
    //toplam kar zarar
    var totalProfitLoss: Double {
        return totalBalance - investedCapital
    }

    //kar zarar yüzdesi
    var totalProfitLossPercentage: Double {
        guard investedCapital > 0 else {
            return 0
        }

        return (totalProfitLoss / investedCapital) * 100
    }
}
