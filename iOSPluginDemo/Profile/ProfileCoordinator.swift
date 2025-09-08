//
//  ProfileCoordinator.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import UIKit
import Swinject

class ProfileCoordinator: NSObject, Coordinator, CoordinatorLifecycle, ModuleCoordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    let moduleType: ModuleType = .profile
    let container: Container
    
    init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
        super.init()
    }
    
    func start() {
        let profileViewController = container.resolve(ProfileViewController.self)!
        navigationController.setViewControllers([profileViewController], animated: false)
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
}