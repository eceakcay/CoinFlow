//
//  Double+Currency.swift
//  CoinFlow
//
//  Created by Ece Akcay on 11.08.2026.
//

import Foundation

extension Double {
    
    func formattedCurrency(_ currency: AppCurrency) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        formatter.locale = Locale(identifier: currency.localeIdentifier)
        
        if abs(self) >= 1_000_000 {
            formatter.maximumFractionDigits = 0
        } else if abs(self) < 1 {
            formatter.maximumFractionDigits = 6
        } else {
            formatter.maximumFractionDigits = 2
        }
        
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    
    func formattedCurrencyWithTwoDigits(_ currency: AppCurrency) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        formatter.locale = Locale(identifier: currency.localeIdentifier)
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
