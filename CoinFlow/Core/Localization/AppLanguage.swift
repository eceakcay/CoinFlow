//
//  AppLanguage.swift
//  CoinFlow
//
//  Created by Ece Akcay on 11.08.2026.
//

import Foundation

enum AppLanguage: String, CaseIterable {
    case english = "English"
    case turkish = "Turkish"

    func displayName(in language: AppLanguage) -> String {
        switch language {
        case .english:
            switch self {
            case .english:
                return "English"
            case .turkish:
                return "Turkish"
            }

        case .turkish:
            switch self {
            case .english:
                return "İngilizce"
            case .turkish:
                return "Türkçe"
            }
        }
    }

    init(value: String) {
        switch value {
        case "Turkish", "Türkçe", "tr":
            self = .turkish
        case "English", "İngilizce", "en":
            self = .english
        default:
            self = .english
        }
    }
}
