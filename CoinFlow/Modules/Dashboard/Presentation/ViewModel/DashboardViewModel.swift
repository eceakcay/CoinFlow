//
//  DashboardViewModel.swift
//  CoinFlow
//
//  Created by Ece Akcay on 5.08.2026.
//

import Foundation

final class DashboardViewModel {
    
    // MARK: - State

    enum State {
        case idle
        case loading
        case success
        case empty
        case partialSuccess(String) //partialSuccess, ekranı dolduracak veri var ama bir kısmı güncel değil demek.
        case failure(String)
    }
    
    // MARK: - Dependencies

    private let fetchDashboardDataUseCase : FetchDashboardDataUseCase
    private let presentationMapper: DashboardPresentationMapper
    private let userDefaultsManager: UserDefaultsManager
    
    // MARK: - Properties

    private(set) var summaryItem : DashboardSummaryItem = .empty
    private(set) var topHoldingItems : [DashboardHoldingItem] = []
    private(set) var recentTransactionItems: [DashboardTransactionItem] = []
    
    var onStateChange: ((State) -> Void)?
    
    private var dashboardTask: Task<Void, Never>?
    
    // MARK: - Init
    
    init(fetchDashboardDataUseCase: FetchDashboardDataUseCase, presentationMapper: DashboardPresentationMapper, userDefaultsManager: UserDefaultsManager) {
        self.fetchDashboardDataUseCase = fetchDashboardDataUseCase
        self.presentationMapper = presentationMapper
        self.userDefaultsManager = userDefaultsManager
    }
    
    // MARK: - Lifecycle

    func viewWillAppear() {
        fetchDashboardData()
    }
    
    // MARK: - Fetch Data

    private func fetchDashboardData() {
        dashboardTask?.cancel() //eski task varsa iptal et
        
        onStateChange?(.loading)
        
        dashboardTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                let vsCurrency = self.userDefaultsManager.appCurrency.apiValue
                let currency = self.userDefaultsManager.appCurrency
                let result = try await self.fetchDashboardDataUseCase.execute(vsCurrency: vsCurrency) //DashboardData ve warningMessage dönüyor
                
                guard !Task.isCancelled else { return }
                
                let dashboardData = result.data
                
                //PortfolioSummary verisini UI’da gösterilecek modele çeviriyoruz.
                let summaryItem = self.presentationMapper.makeSummaryItem(
                    from: dashboardData.portfolioSummary,
                    currency: currency
                )
                
                //PortfolioHolding listesini Dashboard’da gösterilecek holding item’lara çeviriyoruz.
                let holdingItems = self.presentationMapper.makeHoldingItems(
                    from: dashboardData.topHoldings,
                    currency: currency
                )
                
                let transactionItems = self.presentationMapper.makeTransactionItems(
                    from: dashboardData.recentTransactions,
                    currency: currency
                )
                
                //UI ile ilgili state güncellemeleri ana thread’de yapılmalı.
                await MainActor.run {
                    self.summaryItem = summaryItem
                    self.topHoldingItems = holdingItems
                    self.recentTransactionItems = transactionItems

                    if let warningMessage = result.warningMessage { //warninmessage varsa
                        self.onStateChange?(.partialSuccess(warningMessage))
                    } else if dashboardData.portfolioSummary.holdings.isEmpty {
                        self.onStateChange?(.empty)
                    } else {
                        self.onStateChange?(.success)
                    }
                }
            } catch {
                await MainActor.run {
                    self.onStateChange?(.failure(error.localizedDescription))
                }
            }
        }
    }
    
    // MARK: - Public Helpers

    func numberOfTopHoldings() -> Int {
        return topHoldingItems.count
    }

    func topHoldingItem(at index: Int) -> DashboardHoldingItem? {
        guard topHoldingItems.indices.contains(index) else {
            return nil
        }

        return topHoldingItems[index]
    }
    
    func numberOfRecentTransactions() -> Int {
        recentTransactionItems.count
    }

    func recentTransactionItem(at index: Int) -> DashboardTransactionItem? {
        guard recentTransactionItems.indices.contains(index) else {
            return nil
        }
        
        return recentTransactionItems[index]
    }
}
