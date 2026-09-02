//
//  PortfolioTransactionMapper.swift
//  CoinFlow
//
//  Created by Ece Akcay on 24.07.2026.
//
//CoreData modeli: PortfolioTransactionEntity
//Domain modeli: PortfolioTransaction

import Foundation
//CoreData modeli ile Domain modelini birbirine çevirir.
enum PortfolioTransactionMapper {
    
    static func map(_ entity: PortfolioTransactionEntity) -> PortfolioTransaction? {
        guard let type = TransactionType(rawValue: entity.typeRawValue) else {
            return nil
        }
        
        return PortfolioTransaction(
            id: entity.id,
            coinId: entity.coinId,
            coinName: entity.coinName,
            symbol: entity.symbol,
            type: type,
            amount: entity.amount,
            pricePerCoin: entity.pricePerCoin,
            currencyCode: entity.currencyCode.isEmpty ? "USD" : entity.currencyCode,
            date: entity.date
        )
    }
    
    static func fill(_ entity: PortfolioTransactionEntity, with transaction: PortfolioTransaction) {
        entity.id = transaction.id
        entity.coinId = transaction.coinId
        entity.coinName = transaction.coinName
        entity.symbol = transaction.symbol
        entity.typeRawValue = transaction.type.rawValue
        entity.amount = transaction.amount
        entity.pricePerCoin = transaction.pricePerCoin
        entity.currencyCode = transaction.currencyCode
        entity.date = transaction.date
    }
}
