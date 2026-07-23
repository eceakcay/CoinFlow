//
//  ChartTimeRange.swift
//  CoinFlow
//
//  Created by Ece Akcay on 23.07.2026.
//

import Foundation

enum ChartTimeRange: Int, CaseIterable {
    case oneDay = 0
    case sevenDays = 1
    case oneMonth = 2
    case oneYear = 3

    var title: String {
        switch self {
        case .oneDay:
            return "1D"
        case .sevenDays:
            return "7D"
        case .oneMonth:
            return "1M"
        case .oneYear:
            return "1Y"
        }
    }

    var days: Int {
        switch self {
        case .oneDay:
            return 1
        case .sevenDays:
            return 7
        case .oneMonth:
            return 30
        case .oneYear:
            return 365
        }
    }
}
