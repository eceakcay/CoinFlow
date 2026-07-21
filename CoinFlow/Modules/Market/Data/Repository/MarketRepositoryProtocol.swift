//
//  MarketRepositoryProtocol.swift
//  CoinFlow
//
//  Created by Ece Akcay on 14.07.2026.
//

import Foundation

//Bu protokolü, Domain katmanını API detaylarından bağımsız tutmak için yazdık.
//USECASE DOĞRUDAN APİ SERVİSE BAĞLI OLMASIN DİYE PROTOCOL YAZDIK

protocol MarketRepositoryProtocol {
    func fetchMarketCoins (page: Int) async throws -> [CryptoCurrency]
    func searchCoins(query: String) async throws -> [CryptoCurrency]
}

