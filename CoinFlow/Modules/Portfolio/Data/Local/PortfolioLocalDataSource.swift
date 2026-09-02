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

    // MARK: - Properties

    private let context: NSManagedObjectContext
    private let userDefaultsManager: UserDefaultsManager

    // MARK: - Init

    init(
        context: NSManagedObjectContext = CoreDataManager.shared.context,
        userDefaultsManager: UserDefaultsManager = .shared
    ) {
        self.context = context
        self.userDefaultsManager = userDefaultsManager
    }

    // MARK: - Fetch

    // Giriş yapan kullanıcıya ait kayıtları getirir
    func fetchTransactions() throws -> [PortfolioTransaction] {

        guard let currentUserId = userDefaultsManager.activeDataOwnerId else {
            return []
        }

        let request = PortfolioTransactionEntity.fetchRequest()

        request.predicate = NSPredicate(
            format: "ownerUserId == %@",
            currentUserId
        )

        request.sortDescriptors = [
            NSSortDescriptor(
                key: "date",
                ascending: false
            )
        ]

        let entities = try context.fetch(request)
        entities.forEach {
            print("➡️",$0.symbol,"| owner:",$0.ownerUserId ?? "nil")
        }

        return entities.compactMap {
            PortfolioTransactionMapper.map($0)
        }
    }

    // MARK: - Add

    // Yeni işlem ekler
    func addTransaction(_ transaction: PortfolioTransaction) throws {

        guard let currentUserId = userDefaultsManager.activeDataOwnerId else {
            print("❌ Transaction kaydedilemedi - veri sahibi kimliği yok")
            return
        }

        let entity = PortfolioTransactionEntity(context: context)

        PortfolioTransactionMapper.fill(
            entity,
            with: transaction
        )

        entity.ownerUserId = currentUserId

        try saveContextIfNeeded()
    }

    /// Buluttan gelen işlemleri kimliklerine göre ekler veya günceller.
    func upsertTransactions(_ transactions: [PortfolioTransaction]) throws {
        guard let currentUserId = userDefaultsManager.activeDataOwnerId else { return }

        for transaction in transactions {
            let request = PortfolioTransactionEntity.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "id == %@", transaction.id),
                NSPredicate(format: "ownerUserId == %@", currentUserId)
            ])

            let entity = try context.fetch(request).first
                ?? PortfolioTransactionEntity(context: context)
            PortfolioTransactionMapper.fill(entity, with: transaction)
            entity.ownerUserId = currentUserId
        }

        try saveContextIfNeeded()
    }

    // MARK: - Delete

    // ID’ye göre giriş yapan kullanıcıya ait işlemi siler
    func deleteTransaction(id: String) throws {

        guard let currentUserId = userDefaultsManager.activeDataOwnerId else {
            return
        }

        let request = PortfolioTransactionEntity.fetchRequest()

        request.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                NSPredicate(
                    format: "id == %@",
                    id
                ),
                NSPredicate(
                    format: "ownerUserId == %@",
                    currentUserId
                )
            ]
        )

        let entities = try context.fetch(request)

        entities.forEach { entity in
            context.delete(entity)
        }

        try saveContextIfNeeded()
    }

    // Giriş yapan kullanıcıya ait tüm transactionları siler
    func deleteAllTransactions() throws {

        guard let currentUserId = userDefaultsManager.activeDataOwnerId else {
            return
        }

        let request = PortfolioTransactionEntity.fetchRequest()

        request.predicate = NSPredicate(
            format: "ownerUserId == %@",
            currentUserId
        )

        let transactions = try context.fetch(request)

        transactions.forEach { transaction in
            context.delete(transaction)
        }

        try saveContextIfNeeded()
    }

    // MARK: - Private Methods

    private func saveContextIfNeeded() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
