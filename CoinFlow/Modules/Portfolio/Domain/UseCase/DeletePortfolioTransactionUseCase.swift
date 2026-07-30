//
//  DeletePortfolioTransactionUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 30.07.2026.
//

import Foundation

final class DeletePortfolioTransactionUseCase {
    
    private let repository: PortfolioRepositoryProtocol
    
    init(repository: PortfolioRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: String) throws {
        try repository.deleteTransaction(id: id)
    }
}
