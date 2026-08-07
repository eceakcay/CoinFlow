//
//  PortfolioLocalDataSource.swift
//  CoinFlow
//
//  Created by Ece Akcay on 27.07.2026.
//

import Foundation
import CoreData

//CoreData’ya kayıt ekler, kayıtları getirir, kayıt siler.
final class PortfolioLocalDataSource {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    //kayıtları getirir
    func fetchTransactions() throws -> [PortfolioTransaction] {
        let request = PortfolioTransactionEntity.fetchRequest()
        
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)
        ]
        
        let entities = try context.fetch(request)
        
        return entities.compactMap {
            PortfolioTransactionMapper.map($0)
        }
    }
    
    //yeni işlem ekler
    func addTransaction(_ transaction: PortfolioTransaction) throws {
        let entity = PortfolioTransactionEntity(context: context)
        
        PortfolioTransactionMapper.fill(entity, with: transaction)
        
        try saveContextIfNeeded()
    }
    
    //id’ye göre işlem siler
    func deleteTransaction(id : String) throws {
        let request = PortfolioTransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        let entities = try context.fetch(request)
        
        entities.forEach { entity in
            context.delete(entity)
        }
        
        try saveContextIfNeeded()
    }
    
    //tüm transactionları siler
    func deleteAllTransactions() throws {
        let request = PortfolioTransactionEntity.fetchRequest()
        
        let transactions = try context.fetch(request)
        
        transactions.forEach { transaction in
            context.delete(transaction)
        }
        
        try context.save()
    }
    
    private func saveContextIfNeeded() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
