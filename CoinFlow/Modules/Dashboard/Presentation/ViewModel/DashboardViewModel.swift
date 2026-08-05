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
        case partialSuccess(String)
        case failure(String)
    }
    
    // MARK: - Dependencies

    private let fetchDashboardDataUseCase : FetchDashboardDataUseCase
    private let presentationMapper: DashboardPresentationMapper
    
    // MARK: - Properties

    private(set) var summaryItem : DashboardSummaryItem = .empty
    private(set) var topHoldingItems : [DashboardHoldingItem] = []
    
    var onStateChange: ((State) -> Void)?
    
    private var dashboardTask: Task<Void, Never>?
    
    // MARK: - Init
    
    init(fetchDashboardDataUseCase: FetchDashboardDataUseCase, presentationMapper: DashboardPresentationMapper) {
        self.fetchDashboardDataUseCase = fetchDashboardDataUseCase
        self.presentationMapper = presentationMapper
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
                let result = try await self.fetchDashboardDataUseCase.execute()
                
                guard !Task.isCancelled else { return }
                
                let dashboardData = result.data
                
                //PortfolioSummary verisini UI’da gösterilecek modele çeviriyoruz.
                let summaryItem = self.presentationMapper.makeSummaryItem(
                    from: dashboardData.portfolioSummary
                )
                
                //PortfolioHolding listesini Dashboard’da gösterilecek holding item’lara çeviriyoruz.
                let holdingItems = self.presentationMapper.makeHoldingItems(
                    from: dashboardData.topHoldings
                )
                
                //UI ile ilgili state güncellemeleri ana thread’de yapılmalı.
                await MainActor.run {
                    self.summaryItem = summaryItem
                    self.topHoldingItems = holdingItems

                    if let warningMessage = result.warningMessage {
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
    
}
