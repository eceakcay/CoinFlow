//
//  ProfileRowItem.swift
//  CoinFlow
//
//  Created by Ece Akcay on 6.08.2026.
//

import Foundation

enum ProfileRowType {
    case currency
    case language
    case biometric
    case appInfo
    case privacyPolicy
    case signIn
    case resetPortfolio
    case deleteAccount
    case logout
}

enum ProfileAccessoryType {
    case chevron
    case toggle(isOn: Bool)
    case none
}

struct ProfileRowItem {
    let title: String
    let subtitle: String?
    let systemImageName: String
    let type: ProfileRowType
    let accessoryType: ProfileAccessoryType
    let isDestructive: Bool
}
