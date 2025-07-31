//
//  HomeCoordinator.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import UIKit
import Swinject

// MARK: - Home Coordinator
class HomeCoordinator: NSObject, Coordinator, CoordinatorLifecycle, ModuleCoordinator {
    
    // MARK: - Properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    let moduleType: ModuleType = .home
    let container: Container
    
    // MARK: - Initialization
    init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
        super.init()
    }
    
    // MARK: - Coordinator
    func start() {
        let homeViewController = container.resolve(HomeViewController.self)!
        navigationController.setViewControllers([homeViewController], animated: false)
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
    
    // MARK: - Navigation
    func showHomeDetail() {
        // 导航到详情页面
        let detailCoordinator = HomeDetailCoordinator(navigationController: navigationController, container: container)
        addChildCoordinator(detailCoordinator)
        detailCoordinator.start()
    }
}

// MARK: - Home Detail Coordinator
class HomeDetailCoordinator: NSObject, Coordinator, CoordinatorLifecycle {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let container: Container
    
    init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
        super.init()
    }
    
    func start() {
        let detailViewController = container.resolve(HomeDetailViewController.self)!
        navigationController.pushViewController(detailViewController, animated: true)
    }
    
    func finish() {
        childCoordinators.removeAll()
        navigationController.popViewController(animated: true)
    }
} 