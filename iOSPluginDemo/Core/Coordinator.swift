//
//  Coordinator.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import UIKit
import Combine

// MARK: - Coordinator Protocol
protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
    func finish()
}

// MARK: - Coordinator Lifecycle Management
protocol CoordinatorLifecycle {
    func addChildCoordinator(_ coordinator: Coordinator)
    func removeChildCoordinator(_ coordinator: Coordinator)
    func finish()
}

extension CoordinatorLifecycle where Self: Coordinator {
    func addChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
}

enum CoordinatorType {
    case main
    case home
    case profile
    case auth
    case deviceProvisioning
    case deviceControl
    // 添加更多模块的 coordinator 类型
} 