//
//  DashboardDataResult.swift
//  CoinFlow
//
//  Created by Ece Akcay on 5.08.2026.
//

import Foundation

//Bu sayede Dashboard’da partialSuccess state kurabildik.
struct DashboardDataResult {
    let data: DashboardData //Dashboard’da gösterilecek veri
    let warningMessage: String? //başarısızsa popup mesajı
}
