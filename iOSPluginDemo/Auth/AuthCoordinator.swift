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
        // 通知主协调器登录完成
        NotificationCenter.default.post(name: .authDidComplete, object: nil)
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

// MARK: - Notification Names
extension Notification.Name {
    static let authDidComplete = Notification.Name("authDidComplete")
} 