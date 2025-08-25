//
//  DIContainer.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/8/25.
//

import Foundation
import Swinject
import SwiftyBeaver

// MARK: - DIContainer Manager Protocol
protocol DIContainerManager {
    var container: Container { get }
    func registerCoreDependencies()
    func registerModuleDependencies()
    func resolve<T>(_ type: T.Type) -> T?
}

// MARK: - DIContainer Manager Implementation
final class DIContainerManagerImpl: DIContainerManager {
    
    // MARK: - Properties
    private(set) var container = Container()
    
    // MARK: - Singleton
    static let shared = DIContainerManagerImpl()
    
    private init() {
        setupDependencies()
    }
    
    // MARK: - Setup
    private func setupDependencies() {
        AppLogger.di("设置依赖注入容器...")
        registerCoreDependencies()
        registerModuleDependencies()
        AppLogger.di("依赖注入容器设置完成")
    }
    
    // MARK: - Core Dependencies Registration
    func registerCoreDependencies() {
        AppLogger.di("注册核心依赖...")
        
        // 注册认证状态管理器
        container.register(AuthStateManager.self) { _ in
            AuthStateManager.shared
        }.inObjectScope(.container)
        
        // 注册协调器工厂
        container.register(CoordinatorFactory.self) { resolver in
            CoordinatorFactoryImpl(container: resolver as! Container)
        }.inObjectScope(.container)
        
        // 注册模块工厂
        container.register(ModuleFactory.self) { resolver in
            ModuleFactoryImpl(container: resolver as! Container)
        }.inObjectScope(.container)
        
        // 注册生命周期管理器
        container.register(CoordinatorLifecycleManager.self) { _ in
            CoordinatorRegistry.shared
        }.inObjectScope(.container)
    }
    
    // MARK: - Module Dependencies Registration
    func registerModuleDependencies() {
        AppLogger.di("注册模块依赖...")
        registerAuthModule()
        registerHomeModule()
        registerProfileModule()
        registerSettingsModule()
    }
    
    private func registerAuthModule() {
        // 注册认证服务
        container.register(AuthServiceProtocol.self) { resolver in
            let authStateManager = resolver.resolve(AuthStateManager.self)!
            return AuthService(authStateManager: authStateManager)
        }.inObjectScope(.container)
        
        // 注册认证 ViewModel
        container.register(AuthViewModel.self) { resolver in
            let authService = resolver.resolve(AuthServiceProtocol.self)!
            let authStateManager = resolver.resolve(AuthStateManager.self)!
            return AuthViewModel(authService: authService, authStateManager: authStateManager)
        }.inObjectScope(.transient)
        
        // 注册认证 ViewController
        container.register(AuthViewController.self) { resolver in
            let viewModel = resolver.resolve(AuthViewModel.self)!
            return AuthViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
    }
    
    private func registerHomeModule() {
        // 注册首页服务
        container.register(HomeServiceProtocol.self) { _ in
            HomeService()
        }.inObjectScope(.container)
        
        // 注册首页 ViewModel
        container.register(HomeViewModel.self) { resolver in
            let homeService = resolver.resolve(HomeServiceProtocol.self)!
            return HomeViewModel(homeService: homeService)
        }.inObjectScope(.transient)
        
        // 注册首页 ViewController
        container.register(HomeViewController.self) { resolver in
            let viewModel = resolver.resolve(HomeViewModel.self)!
            return HomeViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
    }
    
    private func registerProfileModule() {
        // 注册个人资料 ViewModel
        container.register(ProfileViewModel.self) { resolver in
            let authStateManager = resolver.resolve(AuthStateManager.self)!
            return ProfileViewModel(authStateManager: authStateManager)
        }.inObjectScope(.transient)
        
        // 注册个人资料 ViewController
        container.register(ProfileViewController.self) { resolver in
            let viewModel = resolver.resolve(ProfileViewModel.self)!
            return ProfileViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
    }
    
    private func registerSettingsModule() {
        // 注册设置 ViewModel
        container.register(SettingsViewModel.self) { _ in
            return SettingsViewModel()
        }.inObjectScope(.transient)
        
        // 注册设置 ViewController
        container.register(SettingsViewController.self) { resolver in
            let viewModel = resolver.resolve(SettingsViewModel.self)!
            return SettingsViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
    }
    
    // MARK: - Dependency Resolution
    func resolve<T>(_ type: T.Type) -> T? {
        return container.resolve(type)
    }
    
    /// 安全解析依赖，检查是否正确注册
    func resolveIfPresent<T>(_ type: T.Type, file: String = #file, line: Int = #line, function: String = #function) -> T? {
        guard let resolved = container.resolve(type) else {
            let typeName = String(describing: type)
            let location = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) in \(function)"
            AppLogger.error("[DI] Failed to resolve dependency '\(typeName)' at \(location). Please check if it's properly registered.")
            
            // 记录当前已注册的服务类型以便调试
            logRegisteredServices()
            return nil
        }
        
        AppLogger.debug("[DI] Successfully resolved dependency '\(String(describing: type))'")
        return resolved
    }
    
    /// 强制解析依赖，如果未注册则抛出错误
    func resolveRequired<T>(_ type: T.Type, file: String = #file, line: Int = #line, function: String = #function) -> T {
        guard let resolved = resolveIfPresent(type, file: file, line: line, function: function) else {
            let typeName = String(describing: type)
            let location = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) in \(function)"
            fatalError("[DI] Required dependency '\(typeName)' is not registered. Location: \(location)")
        }
        return resolved
    }
    
    /// 记录当前已注册的服务，用于调试
    private func logRegisteredServices() {
        AppLogger.debug("[DI] Currently registered services:")
        AppLogger.debug("[DI] - AuthStateManager: \(container.resolve(AuthStateManager.self) != nil)")
        AppLogger.debug("[DI] - AuthServiceProtocol: \(container.resolve(AuthServiceProtocol.self) != nil)")
        AppLogger.debug("[DI] - CoordinatorFactory: \(container.resolve(CoordinatorFactory.self) != nil)")
        AppLogger.debug("[DI] - ModuleFactory: \(container.resolve(ModuleFactory.self) != nil)")
        AppLogger.debug("[DI] - HomeServiceProtocol: \(container.resolve(HomeServiceProtocol.self) != nil)")
    }
}

// MARK: - Coordinator Factory Implementation
class CoordinatorFactoryImpl: CoordinatorFactory {
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    func makeCoordinator(for type: CoordinatorType) -> Coordinator {
        switch type {
        case .main:
            let tabBarController = UITabBarController()
            return MainCoordinator(tabBarController: tabBarController, container: container)
            
        case .auth:
            let navigationController = UINavigationController()
            return AuthCoordinator(navigationController: navigationController, container: container)
            
        case .home:
            let navigationController = UINavigationController()
            return HomeCoordinator(navigationController: navigationController, container: container)
            
        case .profile:
            let navigationController = UINavigationController()
            return ProfileCoordinator(navigationController: navigationController, container: container)
        }
    }
    
    func makeAuthCoordinator() -> AuthCoordinator {
        let navigationController = UINavigationController()
        return AuthCoordinator(navigationController: navigationController, container: container)
    }
    
    func makeMainCoordinator() -> MainCoordinator {
        let tabBarController = UITabBarController()
        return MainCoordinator(tabBarController: tabBarController, container: container)
    }
}

// MARK: - Module Factory Implementation
class ModuleFactoryImpl: ModuleFactory {
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    func createModule(for type: ModuleType) -> Module {
        switch type {
        case .auth:
            return AuthModule(container: container)
        case .home:
            return HomeModule(container: container)
        case .profile:
            return ProfileModule(container: container)
        case .settings:
            return SettingsModule(container: container)
        }
    }
}

// MARK: - Container Extension for Safe Resolution
extension Container {
    
    /// 安全解析扩展方法
    func safeResolve<Service>(_ serviceType: Service.Type, file: String = #file, line: Int = #line, function: String = #function) -> Service? {
        return DIContainerManagerImpl.shared.resolveIfPresent(serviceType, file: file, line: line, function: function)
    }
    
    /// 必需解析扩展方法
    func requiredResolve<Service>(_ serviceType: Service.Type, file: String = #file, line: Int = #line, function: String = #function) -> Service {
        return DIContainerManagerImpl.shared.resolveRequired(serviceType, file: file, line: line, function: function)
    }
}

// MARK: - Resolver Extension for Safe Resolution
extension Resolver {
    
    /// 安全解析扩展方法
    func safeResolve<Service>(_ serviceType: Service.Type, file: String = #file, line: Int = #line, function: String = #function) -> Service? {
        guard let resolved = resolve(serviceType) else {
            let typeName = String(describing: serviceType)
            let location = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) in \(function)"
            AppLogger.error("[DI] Failed to resolve dependency '\(typeName)' at \(location). Please check if it's properly registered.")
            return nil
        }
        AppLogger.debug("[DI] Successfully resolved dependency '\(String(describing: serviceType))'")
        return resolved
    }
    
    /// 必需解析扩展方法
    func requiredResolve<Service>(_ serviceType: Service.Type, file: String = #file, line: Int = #line, function: String = #function) -> Service {
        guard let resolved = safeResolve(serviceType, file: file, line: line, function: function) else {
            let typeName = String(describing: serviceType)
            let location = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) in \(function)"
            fatalError("[DI] Required dependency '\(typeName)' is not registered. Location: \(location)")
        }
        return resolved
    }
}