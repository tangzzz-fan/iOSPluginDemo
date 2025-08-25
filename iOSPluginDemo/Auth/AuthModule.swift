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
        container.register(AuthServiceProtocol.self) { resolver in
            // 使用安全解析方法
            guard let authStateManager = resolver.safeResolve(AuthStateManager.self) else {
                AppLogger.fatal("AuthStateManager not registered - Auth module initialization failed")
                fatalError("AuthStateManager not registered")
            }
            return AuthService(authStateManager: authStateManager)
        }.inObjectScope(.container)
        
        // 注册 Auth ViewModel
        container.register(AuthViewModel.self) { resolver in
            // 使用必需解析方法，如果失败则直接崩溃
            let authService = resolver.requiredResolve(AuthServiceProtocol.self)
            let authStateManager = resolver.requiredResolve(AuthStateManager.self)
            return AuthViewModel(authService: authService, authStateManager: authStateManager)
        }.inObjectScope(.transient)
        
        // 注册 Auth ViewController
        container.register(AuthViewController.self) { resolver in
            let viewModel = resolver.requiredResolve(AuthViewModel.self)
            return AuthViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        // 注册 AuthCoordinator
        container.register(AuthCoordinator.self) { resolver in
            let navigationController = UINavigationController()
            return AuthCoordinator(navigationController: navigationController, container: container)
        }.inObjectScope(.transient)
        
        AppLogger.di("Auth module dependencies registered successfully")
    }
} 