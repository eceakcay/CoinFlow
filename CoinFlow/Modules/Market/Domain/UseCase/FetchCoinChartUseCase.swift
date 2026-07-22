//
//  FetchCoinChartUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 22.07.2026.
//

import Foundation

final class FetchCoinChartUseCase {
    
    private let repository: MarketRepositoryProtocol
    
    init(repository: MarketRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(coinId: String, days: Int) async throws -> [CoinChartPoint] {
        return try await repository.fetchCoinChart(coinId: coinId, days: days)
    }
}
