//
//  AddPortfolioTransactionUseCase.swift
//  CoinFlow
//
//  Created by Ece Akcay on 30.07.2026.
//

import Foundation

//yapılan işi temsil eder
final class AddPortfolioTransactionUseCase {
    
    private let repository: PortfolioRepositoryProtocol
    
    init(repository: PortfolioRepositoryProtocol) {
        self.repository = repository
    }
    
    //func dışardan çağrılırken parametre adı vermeye gerek yok 
    func execute(_ transaction: PortfolioTransaction) throws {
        try repository.addTransaction(transaction)
    }
}
