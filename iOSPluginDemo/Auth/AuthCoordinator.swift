//
//  AuthCoordinator.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import UIKit
import Swinject

// MARK: - Auth Coordinator
class AuthCoordinator: NSObject, Coordinator, CoordinatorLifecycle, ModuleCoordinator {
    
    // MARK: - Properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    let moduleType: ModuleType = .auth
    let container: Container
    
    // MARK: - Initialization
    init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
        super.init()
    }
    
    // MARK: - Coordinator
    func start() {
        let authViewController = container.resolve(AuthViewController.self)!
        navigationController.setViewControllers([authViewController], animated: false)
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
    
    // MARK: - Navigation Methods
    func showForgotPassword() {
        let forgotPasswordCoordinator = ForgotPasswordCoordinator(navigationController: navigationController, container: container)
        addChildCoordinator(forgotPasswordCoordinator)
        forgotPasswordCoordinator.start()
    }
    
    func showRegistration() {
        let registrationCoordinator = RegistrationCoordinator(navigationController: navigationController, container: container)
        addChildCoordinator(registrationCoordinator)
        registrationCoordinator.start()
    }
    
    func showMainApp() {
        // 这个方法不再需要发送通知，因为 AuthStateManager 使用 Combine 自动处理
        // 保留这个方法以保持向后兼容，但不做任何操作
    }
    
    func dismissAuth() {
        // 关闭认证界面
        navigationController.dismiss(animated: true)
    }
}

// MARK: - Forgot Password Coordinator
class ForgotPasswordCoordinator: NSObject, Coordinator, CoordinatorLifecycle {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let container: Container
    
    init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
        super.init()
    }
    
    func start() {
        let forgotPasswordViewController = container.resolve(ForgotPasswordViewController.self)!
        navigationController.pushViewController(forgotPasswordViewController, animated: true)
    }
    
    func finish() {
        childCoordinators.removeAll()
        navigationController.popViewController(animated: true)
    }
}

// MARK: - Registration Coordinator
class RegistrationCoordinator: NSObject, Coordinator, CoordinatorLifecycle {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let container: Container
    
    init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
        super.init()
    }
    
    func start() {
        let registrationViewController = container.resolve(RegistrationViewController.self)!
        navigationController.pushViewController(registrationViewController, animated: true)
    }
    
    func finish() {
        childCoordinators.removeAll()
        navigationController.popViewController(animated: true)
    }
} 