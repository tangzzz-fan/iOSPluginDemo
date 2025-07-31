//
//  DIContainer.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import Foundation
import Swinject
import SwiftyBeaver

// MARK: - DI Container Manager
protocol DIContainerManager {
    var container: Container { get }
    func registerCoreDependencies()
    func registerModuleDependencies()
    func resolve<T>(_ type: T.Type) -> T
    func resolve<T>(_ type: T.Type, name: String?) -> T
}

class DIContainerManagerImpl: DIContainerManager {
    
    // MARK: - Properties
    let container = Container()
    private let log = SwiftyBeaver.self
    
    // MARK: - Singleton
    static let shared = DIContainerManagerImpl()
    
    private init() {
        registerCoreDependencies()
        registerModuleDependencies()
    }
    
    // MARK: - Core Dependencies
    func registerCoreDependencies() {
        // 注册日志服务
        container.register(SwiftyBeaver.Type.self) { _ in
            SwiftyBeaver.self
        }.inObjectScope(.container)
        
        // 注册认证状态管理器
        container.register(AuthStateManager.self) { _ in
            AuthStateManager.shared
        }.inObjectScope(.container)
        
        // 注册 Coordinator Factory
        container.register(CoordinatorFactory.self) { _ in
            CoordinatorFactoryImpl()
        }.inObjectScope(.container)
        
        // 注册 Module Factory
        container.register(ModuleFactory.self) { _ in
            ModuleFactoryImpl()
        }.inObjectScope(.container)
        
        log.info("Core dependencies registered")
    }
    
    // MARK: - Module Dependencies
    func registerModuleDependencies() {
        // 注册各个模块
        _ = HomeModule(container: container)
        _ = ProfileModule(container: container)
        _ = SettingsModule(container: container)
        _ = AuthModule(container: container)
        
        // 注册 Home 服务
        container.register(HomeServiceProtocol.self) { _ in
            HomeService()
        }.inObjectScope(.container)
        
        // 注册 HomeDetailViewController
        container.register(HomeDetailViewController.self) { _ in
            HomeDetailViewController()
        }.inObjectScope(.transient)
        
        // 注册 Auth 相关视图控制器
        container.register(ForgotPasswordViewController.self) { _ in
            ForgotPasswordViewController()
        }.inObjectScope(.transient)
        
        container.register(RegistrationViewController.self) { _ in
            RegistrationViewController()
        }.inObjectScope(.transient)
        
        log.info("Module dependencies registered")
    }
    
    // MARK: - Resolution
    func resolve<T>(_ type: T.Type) -> T {
        guard let instance = container.resolve(type) else {
            fatalError("Failed to resolve \(type)")
        }
        return instance
    }
    
    func resolve<T>(_ type: T.Type, name: String?) -> T {
        guard let instance = container.resolve(type, name: name) else {
            fatalError("Failed to resolve \(type) with name: \(name ?? "nil")")
        }
        return instance
    }
    
    /// 安全地解析可能不存在的依赖，返回可选值
    /// - Parameter serviceType: 要解析的服务类型
    /// - Returns: 解析成功的实例，如果不存在则返回 nil
    public func resolveComponentIfPresent<T>(_ serviceType: T.Type) -> T? {
        return container.resolve(serviceType)
    }
    
    /// 安全地解析可能不存在的依赖（带名称），返回可选值
    /// - Parameters:
    ///   - serviceType: 要解析的服务类型
    ///   - name: 服务名称
    /// - Returns: 解析成功的实例，如果不存在则返回 nil
    public func resolveComponentIfPresent<T>(_ serviceType: T.Type, name: String?) -> T? {
        return container.resolve(serviceType, name: name)
    }
}

// MARK: - Coordinator Factory Implementation
class CoordinatorFactoryImpl: CoordinatorFactory {
    func makeCoordinator(for type: CoordinatorType) -> Coordinator {
        let container = DIContainerManagerImpl.shared.container
        
        switch type {
        case .main:
            return MainCoordinator(navigationController: UINavigationController(), container: container)
        case .home:
            return HomeCoordinator(navigationController: UINavigationController(), container: container)
        case .profile:
            return ProfileCoordinator(navigationController: UINavigationController(), container: container)
        case .auth:
            return AuthCoordinator(navigationController: UINavigationController(), container: container)
        }
    }
}

// MARK: - Module Factory Implementation
class ModuleFactoryImpl: ModuleFactory {
    func createModule(for type: ModuleType) -> Module {
        let container = DIContainerManagerImpl.shared.container
        
        switch type {
        case .home:
            return HomeModule(container: container)
        case .profile:
            return ProfileModule(container: container)
        case .settings:
            return SettingsModule(container: container)
        case .auth:
            return AuthModule(container: container)
        }
    }
} 
