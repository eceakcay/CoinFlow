//
//  File.swift
//  CoinFlow
//
//  Created by Ece Akcay on 7.08.2026.
//

import Foundation

final class DeleteAllPortfolioTransactionsUseCase {
    
    private let repository : PortfolioRepositoryProtocol
    
    init(repository: PortfolioRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() throws {
        try repository.deleteAllTransactions()
    }
}

