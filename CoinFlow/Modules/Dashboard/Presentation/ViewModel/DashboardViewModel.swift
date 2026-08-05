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
            
            let dashboardData = await self.fetchDashboardDataUseCase.execute()
            
            guard !Task.isCancelled else { return }
            
            let summaryItem = self.presentationMapper.makeSummaryItem(from: dashboardData.portfolioSummary)
            
            let holdingItem = self.presentationMapper.makeHoldingItems(from: dashboardData.topHoldings)
            
            //UI ile ilgili state güncellemeleri ana thread’de yapılmalı.
            await MainActor.run {
                self.summaryItem = summaryItem
                self.topHoldingItems = holdingItem
                
                if dashboardData.portfolioSummary.holdings.isEmpty {
                    self.onStateChange?(.empty)
                } else {
                    self.onStateChange?(.success)
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
