//
//  SettingsCoordinator.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import UIKit
import Swinject

class SettingsCoordinator: NSObject, Coordinator, CoordinatorLifecycle, ModuleCoordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    let moduleType: ModuleType = .settings
    let container: Container
    
    init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
        super.init()
    }
    
    func start() {
        let settingsViewController = container.resolve(SettingsViewController.self)!
        navigationController.setViewControllers([settingsViewController], animated: false)
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
} 