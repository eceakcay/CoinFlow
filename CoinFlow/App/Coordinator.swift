//
//  Coordinator.swift
//  CoinFlow
//
//  Created by Ece Akcay on 8.07.2026.
//

import Foundation
import UIKit

protocol Coordinator: AnyObject {
    
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
    func finish()
    func childDidFinish(_ child: Coordinator?)
}

extension Coordinator {
    
    func finish() {}
    
    func childDidFinish(_ child: Coordinator?) {
        childCoordinators.removeAll { coordinator in
            coordinator === child
        }
    }
}
