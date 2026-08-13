//
//  PortfolioViewModel.swift
//  CoinFlow
//
//  Created by Ece Akcay on 30.07.2026.
//

import Foundation

final class PortfolioViewModel {
    
    // MARK: - State
    
    enum State {
        case idle
        case loading
        case success
        case empty
        case partialSuccess(String) //yedek çözüm
        case failure(String)
    }
    
    // MARK: - Properties
    
    private let fetchPortfolioTransactionsUseCase: FetchPortfolioTransactionsUseCase
    private let addPortfolioTransactionsUseCase: AddPortfolioTransactionUseCase
    private let deletePortfolioTransactionUseCase: DeletePortfolioTransactionUseCase
    private let calculatePortfolioSummaryUseCase : CalculatePortfolioSummaryUseCase //Portföy toplamlarını hesaplar
    private let userDefaultsManager: UserDefaultsManager

    private(set) var transactions: [PortfolioTransaction] = [] //Portföydeki alış ve satış işlemlerini tutar
    private(set) var summary = PortfolioSummary(holdings: []) //Portföy özetini tutar
    private var summaryTask: Task<Void, Never>?
    private var lastCalculatedCurrency: String?

    var onStateChange: ((State) -> Void)?
    
    // MARK: - Init

    init(
        fetchPortfolioTransactionsUseCase: FetchPortfolioTransactionsUseCase,
        addPortfolioTransactionsUseCase: AddPortfolioTransactionUseCase,
        deletePortfolioTransactionsUseCase: DeletePortfolioTransactionUseCase,
        calculatePortfolioSummaryUseCase: CalculatePortfolioSummaryUseCase,
        userDefaultsManager: UserDefaultsManager
    ) {
        self.fetchPortfolioTransactionsUseCase = fetchPortfolioTransactionsUseCase
        self.addPortfolioTransactionsUseCase = addPortfolioTransactionsUseCase
        self.deletePortfolioTransactionUseCase = deletePortfolioTransactionsUseCase
        self.calculatePortfolioSummaryUseCase = calculatePortfolioSummaryUseCase
        self.userDefaultsManager = userDefaultsManager
    }
    
    // MARK: - Lifecycle

    func viewDidLoad() {
        fetchTransactions()
    }
    
    func viewWillAppear() {
        fetchTransactions()
    }
    
    // MARK: - Actions

    func fetchTransactions() {
        onStateChange?(.loading)
        summaryTask?.cancel() //daha önce çalışan özetTaskı varsa iptal ediyor.
        
        do {
            transactions = try fetchPortfolioTransactionsUseCase.execute() //coredatadan
            
            if transactions.isEmpty {
                summary = PortfolioSummary(holdings: [])
                lastCalculatedCurrency = userDefaultsManager.appCurrency.apiValue
                onStateChange?(.empty)
                return
            }
            
            let currentTransactions = transactions //kopya alınıyor
            
            summaryTask = Task { [weak self] in
                guard let self else { return }
                
                //özet hesaplanıyor
                let vsCurrency = self.userDefaultsManager.appCurrency.apiValue
                let result = await self.calculatePortfolioSummaryUseCase.execute(transactions: currentTransactions,vsCurrency: vsCurrency)
                
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    self.summary = result.summary
                    self.lastCalculatedCurrency = vsCurrency
                    
                    if let warningMessage = result.warningMessage {
                        self.onStateChange?(.partialSuccess(warningMessage))
                    } else {
                        self.onStateChange?(.success)
                    }
                }
            }
        } catch {
            onStateChange?(.failure(error.localizedDescription))
        }
    }
    
    //yeni işlem ekleniyor
    func addTransaction(coinId: String, coinName: String, symbol: String, type: TransactionType, amount: Double, pricePerCoin:Double
    ) {
        
        let transaction = PortfolioTransaction(coinId: coinId, coinName: coinName, symbol: symbol, type: type, amount: amount, pricePerCoin: pricePerCoin) //domain modeli oluşturduk
        
        do {
            try addPortfolioTransactionsUseCase.execute(transaction)
            fetchTransactions() //işlem başarılı olursa
        } catch {
            onStateChange?(.failure(error.localizedDescription))
        }
    }
    
    //silme işlemi
    func deleteTransaction(at index: Int) {
        guard transactions.indices.contains(index) else { //index geçerli mi konrtol ediyor
            return
        }

        let transaction = transactions[index]

        do {
            try deletePortfolioTransactionUseCase.execute(id: transaction.id)
            fetchTransactions()
        } catch {
            onStateChange?(.failure(error.localizedDescription))
        }
    }
    
    // MARK: - Data Source Helpers

    //TableView kaç hücre göstereceği
    func numberOfRows() -> Int {
        return transactions.count
    }
    
    //İndex güvenliyse işlemi döndürür değilse nil
    func transaction(at index: Int) -> PortfolioTransaction? {
        guard transactions.indices.contains(index) else { return nil }
        
        return transactions[index]
    }
    
    //Hücre modelini hazırlar
    func cellItem(at index: Int) -> PortfolioTransactionCellItem? {
           guard let transaction = transaction(at: index) else {
               return nil
           }
        
        let totalPaid = transaction.amount * transaction.pricePerCoin
        let typeText = transaction.type == .buy ? L10n.text(.buy) : L10n.text(.sell)

           return PortfolioTransactionCellItem(
               titleText: transaction.coinName,
               subtitleText: transaction.symbol.uppercased(),
               amountText: formatAmount(transaction.amount, symbol: transaction.symbol),//miktar
               priceText: formatCurrency(transaction.pricePerCoin),//fiyat
               totalPaidText: "\(L10n.text(.totalPaid)) \(formatCurrency(totalPaid))",
               dateText: formatDate(transaction.date),
               typeText: typeText //buy? sell?
           )
       }
    
    // MARK: - Formatting

    private func formatAmount(_ amount: Double,symbol: String) -> String {
        return "\(amount) \(symbol.uppercased())"
    }

    private func formatCurrency(_ value: Double) -> String {
        let currency = userDefaultsManager.appCurrency
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        formatter.locale = Locale(identifier: currency.localeIdentifier)
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(
            identifier: UserDefaultsManager.shared.appLanguage == .turkish ? "tr_TR" : "en_US"
        )
        return formatter.string(from: date)
    }
    
    private func formatSignedCurrency(_ value: Double) -> String {
        if value == 0 {
            return formatCurrency(0)
        }

        let formattedValue = formatCurrency(abs(value))

        return value > 0
            ? "+\(formattedValue)"
            : "-\(formattedValue)"
    }

    private func formatSignedPercentage(_ value: Double) -> String {
        if value == 0 {
            return "0.00%"
        }

        return value > 0
            ? String(format: "+%.2f%%", value)
            : String(format: "%.2f%%", value)
    }
    
    // MARK: - Display Properties
    
    var totalBalanceText: String {
        return formatCurrency(summary.totalBalance)
    }

    var investedCapitalText: String {
        return formatCurrency(summary.investedCapital)
    }

    var profitLossText: String {
        return formatSignedCurrency(summary.totalProfitLoss)
    }

    var profitLossPercentageText: String {
        return formatSignedPercentage(summary.totalProfitLossPercentage)
    }

    var isProfit: Bool { //kar varsa true
        return summary.totalProfitLoss >= 0
    }

    private var totalInvestedAmount: Double {
        return transactions.reduce(0) { result, transaction in
            let transactionValue = transaction.amount * transaction.pricePerCoin

            switch transaction.type {
            case .buy:
                return result + transactionValue
            case .sell:
                return result - transactionValue
            }
        }
    }
    
    
}
