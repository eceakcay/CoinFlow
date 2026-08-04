//
//  UIViewController+Alert.swift
//  CoinFlow
//
//  Created by Ece Akcay on 4.08.2026.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String) {
        guard presentedViewController == nil else { return }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert,animated: true)
    }
    
    func showNetworkErrorAlert(message: String) {
        showAlert(title: "Connection Error", message: message)
    }
}
