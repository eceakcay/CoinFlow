//
//  AppCurrency.swift
//  CoinFlow
//
//  Created by Ece Akcay on 7.08.2026.
//

import Foundation

enum AppCurrency : String, CaseIterable {
    case usd = "USD"
    case eur = "EUR"
    case turkshLira = "TRY"
    
    var apiValue: String {
        rawValue.lowercased()
    }
    
    var localeIdentifier: String {
        switch self {
        case .usd:
            return "en_US"
        case .eur:
            return "de_DE"
        case .turkshLira:
            return "tr_TR"
        }
    }
    
    init(code: String) {
        self = AppCurrency(rawValue: code) ?? .usd
    }
}
