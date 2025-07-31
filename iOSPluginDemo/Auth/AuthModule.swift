//
//  AuthModule.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import Foundation
import Swinject

// MARK: - Auth Module
class AuthModule: Module {
    let name = "Auth"
    let coordinator: Coordinator
    private let container: Container
    
    init(container: Container) {
        self.container = container
        self.coordinator = AuthCoordinator(navigationController: UINavigationController(), container: container)
        registerDependencies(in: container)
    }
    
    func registerDependencies(in container: Container) {
        // 注册 Auth 服务
        container.register(AuthServiceProtocol.self) { _ in
            AuthService()
        }.inObjectScope(.container)
        
        // 注册 Auth ViewModel
        container.register(AuthViewModel.self) { resolver in
            let authService = resolver.resolve(AuthServiceProtocol.self)!
            return AuthViewModel(authService: authService)
        }.inObjectScope(.transient)
        
        // 注册 Auth ViewController
        container.register(AuthViewController.self) { resolver in
            let viewModel = resolver.resolve(AuthViewModel.self)!
            return AuthViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        // 注册 AuthCoordinator
        container.register(AuthCoordinator.self) { resolver in
            let navigationController = UINavigationController()
            return AuthCoordinator(navigationController: navigationController, container: container)
        }.inObjectScope(.transient)
    }
} 