//
//  PortfolioTransactionEntity.swift
//  CoinFlow
//
//  Created by Ece Akcay on 24.07.2026.
//

import Foundation
import CoreData

//CoreData içinde saklanan modeldir.
@objc(PortfolioTransactionEntity)
final class PortfolioTransactionEntity: NSManagedObject {
    
    @NSManaged var id: String
    @NSManaged var coinId: String
    @NSManaged var coinName: String
    @NSManaged var symbol: String
    @NSManaged var type: String
    @NSManaged var amount: Double
    @NSManaged var pricePerCoin: Double
    @NSManaged var date: Date
}

extension PortfolioTransactionEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<PortfolioTransactionEntity> {
        return NSFetchRequest<PortfolioTransactionEntity>(
            entityName: "PortfolioTransactionEntity"
        )
    }
}
