//
//  NetworkConnectionMonitor.swift
//  CoinFlow
//

import Foundation
import Network

protocol NetworkConnectionProviding {
    var isConnected: Bool { get }
}

final class NetworkConnectionMonitor: NetworkConnectionProviding {

    static let shared = NetworkConnectionMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.eceakcay.CoinFlow.network-monitor")
    private let lock = NSLock()
    private var connected = false

    var isConnected: Bool {
        lock.withLock { connected }
    }

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.lock.withLock {
                self?.connected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
