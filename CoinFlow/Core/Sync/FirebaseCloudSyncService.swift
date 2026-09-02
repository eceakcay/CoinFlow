import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Kayıtlı kullanıcı verilerini Firestore ile eşitler. Yerel veri çevrimdışı
/// önbellek olarak kalır; misafir verileri hiçbir zaman buluta gönderilmez.
final class FirebaseCloudSyncService {
    struct UserDataBackup {
        fileprivate let userData: [String: Any]?
        fileprivate let transactions: [(id: String, data: [String: Any])]
        fileprivate let preferences: [(id: String, data: [String: Any])]
        fileprivate let favorites: [(id: String, data: [String: Any])]
    }

    private let database: Firestore
    private let userDefaultsManager: UserDefaultsManager

    init(
        database: Firestore = Firestore.firestore(),
        userDefaultsManager: UserDefaultsManager = .shared
    ) {
        self.database = database
        self.userDefaultsManager = userDefaultsManager
    }

    private var userDocument: DocumentReference? {
        guard !userDefaultsManager.isGuestMode,
              let userId = Auth.auth().currentUser?.uid else { return nil }
        return database.collection("users").document(userId)
    }

    func synchronize(
        portfolio: PortfolioLocalDataSource,
        favorites: FavoriteLocalDataSource
    ) async throws {
        guard let userDocument else { return }

        let userSnapshot = try await userDocument.getDocument()
        let hasCloudState = userSnapshot.data()?["syncVersion"] != nil
        let cloudTransactions = try await fetchTransactions(from: userDocument)
        let localTransactions = try portfolio.fetchTransactions()
        if hasCloudState {
            try portfolio.deleteAllTransactions()
            try portfolio.upsertTransactions(cloudTransactions)
        } else if !localTransactions.isEmpty {
            try await uploadTransactions(localTransactions, to: userDocument)
        }

        let favoriteDocuments = try await userDocument.collection("favorites").getDocuments()
        let usesPerCoinFavorites = userSnapshot.data()?["favoritesVersion"] as? Int == 2

        if usesPerCoinFavorites {
            favorites.replaceFavoriteIds(favoriteDocuments.documents.map(\.documentID))
        } else {
            // Eski tek-belge favori yapısını bir kez coin başına belge yapısına
            // taşı. Böylece farklı cihazlardaki farklı coin değişiklikleri
            // artık birbirinin listesini ezmez.
            let legacySnapshot = try await userDocument
                .collection("preferences").document("favorites").getDocument()
            let legacyIds = legacySnapshot.data()?["coinIds"] as? [String] ?? []
            let initialIds = legacySnapshot.exists
                ? legacyIds
                : favorites.getFavoriteIds()
            try await uploadFavoriteDocuments(initialIds, to: userDocument)
            favorites.replaceFavoriteIds(initialIds)
        }

        try await userDocument.setData([
            "syncVersion": 1,
            "favoritesVersion": 2,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }

    func saveTransaction(_ transaction: PortfolioTransaction) async throws {
        guard let document = userDocument?.collection("transactions").document(transaction.id) else { return }
        try await document.setData(transactionData(transaction))
    }

    func deleteTransaction(id: String) async throws {
        guard let document = userDocument?.collection("transactions").document(id) else { return }
        try await document.delete()
    }

    func deleteAllTransactions() async throws {
        guard let userDocument else { return }
        let snapshot = try await userDocument.collection("transactions").getDocuments()
        let batch = database.batch()
        snapshot.documents.forEach { batch.deleteDocument($0.reference) }
        try await batch.commit()
    }

    // Bu metotlar Task başlatmadan doğrudan çağrılır. Firestore mutasyonu
    // çağrı anında kendi kalıcı çevrimdışı kuyruğuna ekler ve çağrı sırasını
    // bağlantı geri geldiğinde de korur.
    func enqueueSaveTransaction(_ transaction: PortfolioTransaction) {
        guard let document = userDocument?.collection("transactions").document(transaction.id) else { return }
        document.setData(transactionData(transaction))
    }

    func enqueueDeleteTransaction(id: String) {
        guard let document = userDocument?.collection("transactions").document(id) else { return }
        document.delete()
    }

    func enqueueAddFavorite(id: String) {
        guard let document = userDocument?.collection("favorites").document(id) else { return }
        document.setData(["createdAt": FieldValue.serverTimestamp()])
    }

    func enqueueRemoveFavorite(id: String) {
        guard let document = userDocument?.collection("favorites").document(id) else { return }
        document.delete()
    }

    func waitForPendingWrites() async throws {
        try await database.waitForPendingWrites()
    }

    /// Authentication hesabı silinmeden önce kullanıcıya ait bütün Firestore
    /// belgelerini temizler. Sonrasında güvenlik kuralları erişime izin vermez.
    func deleteAllUserData() async throws {
        guard let userDocument else { return }
        try await deleteDocuments(in: userDocument.collection("transactions"))
        try await userDocument.collection("preferences").document("favorites").delete()
        try await deleteDocuments(in: userDocument.collection("favorites"))
        try await userDocument.delete()
    }

    /// Hesap silme işleminin Auth adımında başarısız olması halinde Firestore
    /// verilerinin geri getirilebilmesi için silme öncesi anlık görüntü alır.
    func makeUserDataBackup() async throws -> UserDataBackup {
        guard let userDocument else {
            return UserDataBackup(userData: nil, transactions: [], preferences: [], favorites: [])
        }

        async let userSnapshot = userDocument.getDocument()
        async let transactionSnapshot = userDocument.collection("transactions").getDocuments()
        async let preferenceSnapshot = userDocument
            .collection("preferences").document("favorites").getDocument()
        async let favoriteSnapshot = userDocument.collection("favorites").getDocuments()

        let (user, transactions, preferences, favorites) = try await (
            userSnapshot,
            transactionSnapshot,
            preferenceSnapshot,
            favoriteSnapshot
        )

        return UserDataBackup(
            userData: user.data(),
            transactions: transactions.documents.map { ($0.documentID, $0.data()) },
            preferences: preferences.data().map { [(preferences.documentID, $0)] } ?? [],
            favorites: favorites.documents.map { ($0.documentID, $0.data()) }
        )
    }

    func restoreUserData(from backup: UserDataBackup) async throws {
        guard let userDocument else { return }

        if let userData = backup.userData {
            try await userDocument.setData(userData)
        }

        try await restoreDocuments(
            backup.transactions,
            in: userDocument.collection("transactions")
        )
        try await restoreDocuments(
            backup.preferences,
            in: userDocument.collection("preferences")
        )
        try await restoreDocuments(
            backup.favorites,
            in: userDocument.collection("favorites")
        )
    }

    private func deleteDocuments(in collection: CollectionReference) async throws {
        while true {
            let snapshot = try await collection.limit(to: 400).getDocuments()
            guard !snapshot.documents.isEmpty else { return }

            let batch = database.batch()
            snapshot.documents.forEach { batch.deleteDocument($0.reference) }
            try await batch.commit()
        }
    }

    private func restoreDocuments(
        _ documents: [(id: String, data: [String: Any])],
        in collection: CollectionReference
    ) async throws {
        for chunkStart in stride(from: 0, to: documents.count, by: 400) {
            let chunkEnd = min(chunkStart + 400, documents.count)
            let batch = database.batch()

            for document in documents[chunkStart..<chunkEnd] {
                batch.setData(document.data, forDocument: collection.document(document.id))
            }

            try await batch.commit()
        }
    }

    private func fetchTransactions(from userDocument: DocumentReference) async throws -> [PortfolioTransaction] {
        let snapshot = try await userDocument.collection("transactions").getDocuments()
        return snapshot.documents.compactMap { document in
            let data = document.data()
            guard let coinId = data["coinId"] as? String,
                  let coinName = data["coinName"] as? String,
                  let symbol = data["symbol"] as? String,
                  let typeRawValue = data["type"] as? String,
                  let type = TransactionType(rawValue: typeRawValue),
                  let amount = data["amount"] as? Double,
                  let pricePerCoin = data["pricePerCoin"] as? Double,
                  let timestamp = data["date"] as? Timestamp else { return nil }

            let currencyCode = (data["currencyCode"] as? String) ?? "USD"

            return PortfolioTransaction(
                id: document.documentID, coinId: coinId, coinName: coinName,
                symbol: symbol, type: type, amount: amount,
                pricePerCoin: pricePerCoin, currencyCode: currencyCode,
                date: timestamp.dateValue()
            )
        }
    }

    private func uploadTransactions(
        _ transactions: [PortfolioTransaction],
        to userDocument: DocumentReference
    ) async throws {
        for chunkStart in stride(from: 0, to: transactions.count, by: 400) {
            let chunkEnd = min(chunkStart + 400, transactions.count)
            let batch = database.batch()

            for transaction in transactions[chunkStart..<chunkEnd] {
                let document = userDocument.collection("transactions").document(transaction.id)
                batch.setData(transactionData(transaction), forDocument: document)
            }

            try await batch.commit()
        }
    }

    private func uploadFavoriteDocuments(
        _ ids: [String],
        to userDocument: DocumentReference
    ) async throws {
        let uniqueIds = Array(Set(ids))
        for chunkStart in stride(from: 0, to: uniqueIds.count, by: 400) {
            let chunkEnd = min(chunkStart + 400, uniqueIds.count)
            let batch = database.batch()

            for id in uniqueIds[chunkStart..<chunkEnd] {
                batch.setData(
                    ["createdAt": FieldValue.serverTimestamp()],
                    forDocument: userDocument.collection("favorites").document(id)
                )
            }

            try await batch.commit()
        }
    }

    private func transactionData(_ transaction: PortfolioTransaction) -> [String: Any] {
        [
            "coinId": transaction.coinId,
            "coinName": transaction.coinName,
            "symbol": transaction.symbol,
            "type": transaction.type.rawValue,
            "amount": transaction.amount,
            "pricePerCoin": transaction.pricePerCoin,
            "currencyCode": transaction.currencyCode,
            "date": Timestamp(date: transaction.date),
            "updatedAt": FieldValue.serverTimestamp()
        ]
    }
}
