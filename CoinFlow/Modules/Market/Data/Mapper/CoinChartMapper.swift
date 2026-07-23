//
//  CoinChartMapper.swift
//  CoinFlow
//
//  Created by Ece Akcay on 21.07.2026.
//

import Foundation

//sadece function tutuyor, nesne oluşturmuyor o yüzden enum
enum CoinChartMapper {
    
    static func map(_ dto: CoinChartDTO) -> [CoinChartPoint] {
        
        return dto.prices.compactMap { item in
            guard item.count >= 2 else {
                return nil
            }
            
            return CoinChartPoint(
                timestamp: item[0],
                price: item[1]
            )
        }
    }
}
