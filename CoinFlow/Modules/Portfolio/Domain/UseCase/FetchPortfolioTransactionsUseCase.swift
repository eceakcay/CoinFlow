//
//  FetchPortfolioTransactionsUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 30.07.2026.
//

import Foundation

final class FetchPortfolioTransactionsUseCase {
    
    private let repository: PortfolioRepositoryProtocol
    
    init(repository: PortfolioRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() throws -> [PortfolioTransaction] {
        return try repository.fetchTransactions()
    }
    
}
