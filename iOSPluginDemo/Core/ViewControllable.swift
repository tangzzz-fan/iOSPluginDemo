//
//  ViewControllable.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import UIKit
import Combine

// MARK: - View Controller Protocol
protocol ViewControllable: UIViewController {
    var cancellables: Set<AnyCancellable> { get set }
    
    func setupUI()
    func bindViewModel()
    func setupNavigationBar()
}

// MARK: - View Controller Lifecycle
protocol ViewControllerLifecycle {
    func viewDidLoad()
    func viewWillAppear(_ animated: Bool)
    func viewDidAppear(_ animated: Bool)
    func viewWillDisappear(_ animated: Bool)
    func viewDidDisappear(_ animated: Bool)
}

// MARK: - View Controller Helper
protocol ViewControllerHelper {
    func showAlert(title: String, message: String, actions: [UIAlertAction]?)
    func showLoading()
    func hideLoading()
    func showError(_ error: Error)
}

// MARK: - Default Implementation
extension ViewControllable {
    func setupUI() {
        view.backgroundColor = .systemBackground
    }
    
    func bindViewModel() {
        // Override in conforming types
    }
    
    func setupNavigationBar() {
        // Override in conforming types
    }
}

extension ViewControllerHelper where Self: UIViewController {
    func showAlert(title: String, message: String, actions: [UIAlertAction]? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let actions = actions, !actions.isEmpty {
            actions.forEach { alert.addAction($0) }
        } else {
            alert.addAction(UIAlertAction(title: "确定", style: .default))
        }
        
        present(alert, animated: true)
    }
    
    func showLoading() {
        // Override in conforming types
    }
    
    func hideLoading() {
        // Override in conforming types
    }
    
    func showError(_ error: Error) {
        showAlert(title: "错误", message: error.localizedDescription)
    }
} 