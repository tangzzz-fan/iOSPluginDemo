//
//  DependencyInjection.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/8/25.
//

import Foundation
import Swinject
import Combine
import SwiftyBeaver

// MARK: - Dependency Container Protocol
protocol DependencyContainer {
    func registerCore()
    func registerFeatureModules() 
    func registerPresentationLayer()
    func validateDependencies() throws
    func resolveDependencies() -> Bool
}

// MARK: - Dependency Registration Strategy
enum DependencyScope {
    case singleton
    case transient
    case weakSingleton
    case scoped(String)
}

protocol DependencyRegistrable {
    var registrationKey: String { get }
    var scope: DependencyScope { get }
    func register(in container: Container)
}

// MARK: - App Container
final class AppContainer: DependencyContainer {
    
    // MARK: - Properties
    private let container = Container()
    private var registrations: [DependencyRegistrable] = []
    private var dependencyGraph: DependencyGraph = DependencyGraph()
    
    // MARK: - Singleton
    static let shared = AppContainer()
    private init() {}
    
    // MARK: - Public Interface
    func getContainer() -> Container {
        return container
    }
    
    func setupDependencies() throws {
        SwiftyBeaver.info("Setting up dependency injection...")
        
        registerCore()
        registerFeatureModules()
        registerPresentationLayer()
        
        try validateDependencies()
        
        SwiftyBeaver.info("Dependency injection setup completed")
    }
    
    // MARK: - Core Registration
    func registerCore() {
        SwiftyBeaver.info("Registering core dependencies...")
        
        // 注册核心状态管理
        container.register(AuthStateManager.self) { _ in
            AuthStateManager.shared
        }.inObjectScope(.container)
        
        // 注册核心服务
        container.register(AuthServiceProtocol.self) { _ in
            let authStateManager = AuthStateManager.shared
            return AuthService(authStateManager: authStateManager)
        }.inObjectScope(.container)
        
        // 注册 Coordinator 工厂
        container.register(CoordinatorFactory.self) { resolver in
            DefaultCoordinatorFactory(container: resolver as! Container)
        }.inObjectScope(.container)
        
        // 注册 Coordinator 生命周期管理器
        container.register(CoordinatorLifecycleManager.self) { _ in
            CoordinatorRegistry.shared
        }.inObjectScope(.container)
        
        dependencyGraph.addNode("AuthStateManager", dependencies: [])
        dependencyGraph.addNode("AuthService", dependencies: [])
        dependencyGraph.addNode("CoordinatorFactory", dependencies: ["Container"])
        dependencyGraph.addNode("CoordinatorLifecycleManager", dependencies: [])
    }
    
    // MARK: - Feature Module Registration
    func registerFeatureModules() {
        SwiftyBeaver.info("Registering feature modules...")
        
        registerAuthModule()
        registerMainModule()
        registerHomeModule()
        registerDemoModule()
        registerProfileModule()
        registerSettingsModule()
    }
    
    private func registerAuthModule() {
        // 注册 Auth ViewModel
        container.register(AuthViewModel.self) { resolver in
            let authService = resolver.resolve(AuthServiceProtocol.self)!
            let authStateManager = resolver.resolve(AuthStateManager.self)!
            return AuthViewModel(authService: authService, authStateManager: authStateManager)
        }.inObjectScope(.transient)
        
        dependencyGraph.addNode("AuthViewModel", dependencies: ["AuthService", "AuthStateManager"])
    }
    
    private func registerMainModule() {
        // 注册 Main 相关依赖
        container.register(MainCoordinator.self) { resolver in
            let tabBarController = UITabBarController()
            return MainCoordinator(tabBarController: tabBarController, container: resolver as! Container)
        }.inObjectScope(.transient)
        
        dependencyGraph.addNode("MainCoordinator", dependencies: ["Container"])
    }
    
    private func registerSettingsModule() {
        // 注册 Settings ViewModel
        container.register(SettingsViewModel.self) { _ in
            return SettingsViewModel()
        }.inObjectScope(.transient)
        
        dependencyGraph.addNode("SettingsViewModel", dependencies: ["AuthStateManager"])
    }
    
    private func registerHomeModule() {
        // 注册 Home 服务
        container.register(HomeServiceProtocol.self) { _ in
            HomeService()
        }.inObjectScope(.container)
        
        // 注册 Home ViewModel
        container.register(HomeViewModel.self) { resolver in
            let homeService = resolver.resolve(HomeServiceProtocol.self)!
            return HomeViewModel(homeService: homeService)
        }.inObjectScope(.transient)
        
        dependencyGraph.addNode("HomeService", dependencies: [])
        dependencyGraph.addNode("HomeViewModel", dependencies: ["HomeService"])
    }
    
    private func registerDemoModule() {
        // 注册截图服务
        container.register(ScreenshotGenerating.self) { _ in
            return ScreenshotGenerator()
        }.inObjectScope(.container)
        
        // 注册 Demo ViewModel
        container.register(DemoListViewModel.self) { _ in
            return DemoListViewModel()
        }.inObjectScope(.transient)
        
        // 注册长截图演示ViewModel
        container.register(LongScreenshotDemoViewModel.self) { resolver in
            let screenshotService = resolver.resolve(ScreenshotGenerating.self)!
            return LongScreenshotDemoViewModel(screenshotService: screenshotService)
        }.inObjectScope(.transient)
        
        dependencyGraph.addNode("ScreenshotService", dependencies: [])
        dependencyGraph.addNode("DemoListViewModel", dependencies: [])
        dependencyGraph.addNode("LongScreenshotDemoViewModel", dependencies: ["ScreenshotService"])
    }
    
    private func registerProfileModule() {
        // 注册 Profile ViewModel
        container.register(ProfileViewModel.self) { resolver in
            let authStateManager = resolver.resolve(AuthStateManager.self)!
            return ProfileViewModel(authStateManager: authStateManager)
        }.inObjectScope(.transient)
        
        dependencyGraph.addNode("ProfileViewModel", dependencies: ["AuthStateManager"])
    }
    
    // MARK: - Presentation Layer Registration
    func registerPresentationLayer() {
        SwiftyBeaver.info("Registering presentation layer...")
        
        // 注册 ViewControllers
        container.register(AuthViewController.self) { resolver in
            let viewModel = resolver.resolve(AuthViewModel.self)!
            return AuthViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(SettingsViewController.self) { resolver in
            let viewModel = resolver.resolve(SettingsViewModel.self)!
            return SettingsViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(HomeViewController.self) { resolver in
            let viewModel = resolver.resolve(HomeViewModel.self)!
            return HomeViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(ProfileViewController.self) { resolver in
            let viewModel = resolver.resolve(ProfileViewModel.self)!
            return ProfileViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(DemoListViewController.self) { resolver in
            let viewModel = resolver.resolve(DemoListViewModel.self)!
            return DemoListViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(LongScreenshotDemoViewController.self) { resolver in
            let viewModel = resolver.resolve(LongScreenshotDemoViewModel.self)!
            return LongScreenshotDemoViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        dependencyGraph.addNode("AuthViewController", dependencies: ["AuthViewModel"])
        dependencyGraph.addNode("SettingsViewController", dependencies: ["SettingsViewModel"])
        dependencyGraph.addNode("HomeViewController", dependencies: ["HomeViewModel"])
        dependencyGraph.addNode("ProfileViewController", dependencies: ["ProfileViewModel"])
        dependencyGraph.addNode("DemoListViewController", dependencies: ["DemoListViewModel"])
        dependencyGraph.addNode("LongScreenshotDemoViewController", dependencies: ["LongScreenshotDemoViewModel"])
    }
    
    // MARK: - Dependency Validation
    func validateDependencies() throws {
        SwiftyBeaver.info("Validating dependencies...")
        
        // 检查循环依赖
        if let cycle = dependencyGraph.detectCycle() {
            throw DependencyError.cyclicDependency(cycle)
        }
        
        // 检查缺失依赖
        let missingDependencies = checkMissingDependencies()
        if !missingDependencies.isEmpty {
            throw DependencyError.missingDependencies(missingDependencies)
        }
        
        SwiftyBeaver.info("Dependency validation passed")
    }
    
    func resolveDependencies() -> Bool {
        do {
            // 测试关键依赖是否能正确解析
            let _ = container.resolve(AuthStateManager.self)
            let _ = container.resolve(AuthServiceProtocol.self)
            let _ = container.resolve(CoordinatorFactory.self)
            
            SwiftyBeaver.info("Dependency resolution test passed")
            return true
        } catch {
            SwiftyBeaver.error("Dependency resolution failed: \(error)")
            return false
        }
    }
    
    // MARK: - Helper Methods
    private func checkMissingDependencies() -> [String] {
        // 检查是否有未注册的依赖
        var missing: [String] = []
        
        for node in dependencyGraph.getAllNodes() {
            for dependency in dependencyGraph.getDependencies(for: node) {
                if !dependencyGraph.hasNode(dependency) {
                    missing.append(dependency)
                }
            }
        }
        
        return Array(Set(missing))
    }
}

// MARK: - Coordinator Factory Protocol
protocol CoordinatorFactory {
    func makeAuthCoordinator() -> AuthCoordinator
    func makeMainCoordinator() -> MainCoordinator
}

// MARK: - Default Coordinator Factory
class DefaultCoordinatorFactory: CoordinatorFactory {
    private let container: Container
    
    init(container: Container) {
        self.container = container
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

// MARK: - Dependency Graph
class DependencyGraph {
    private var nodes: Set<String> = []
    private var edges: [String: Set<String>] = [:]
    
    func addNode(_ node: String, dependencies: [String] = []) {
        nodes.insert(node)
        edges[node] = Set(dependencies)
    }
    
    func hasNode(_ node: String) -> Bool {
        return nodes.contains(node)
    }
    
    func getAllNodes() -> [String] {
        return Array(nodes)
    }
    
    func getDependencies(for node: String) -> [String] {
        return Array(edges[node] ?? [])
    }
    
    func detectCycle() -> [String]? {
        var visited: Set<String> = []
        var recursionStack: Set<String> = []
        var path: [String] = []
        
        for node in nodes {
            if !visited.contains(node) {
                if let cycle = dfs(node: node, visited: &visited, recursionStack: &recursionStack, path: &path) {
                    return cycle
                }
            }
        }
        
        return nil
    }
    
    private func dfs(node: String, visited: inout Set<String>, recursionStack: inout Set<String>, path: inout [String]) -> [String]? {
        visited.insert(node)
        recursionStack.insert(node)
        path.append(node)
        
        if let dependencies = edges[node] {
            for dependency in dependencies {
                if !visited.contains(dependency) {
                    if let cycle = dfs(node: dependency, visited: &visited, recursionStack: &recursionStack, path: &path) {
                        return cycle
                    }
                } else if recursionStack.contains(dependency) {
                    // 找到循环，返回路径
                    if let startIndex = path.firstIndex(of: dependency) {
                        return Array(path[startIndex...])
                    }
                }
            }
        }
        
        recursionStack.remove(node)
        path.removeLast()
        return nil
    }
}

// MARK: - Dependency Errors
enum DependencyError: Error, LocalizedError {
    case cyclicDependency([String])
    case missingDependencies([String])
    case resolutionFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .cyclicDependency(let cycle):
            return "Cyclic dependency detected: \(cycle.joined(separator: " -> "))"
        case .missingDependencies(let missing):
            return "Missing dependencies: \(missing.joined(separator: ", "))"
        case .resolutionFailed(let type):
            return "Failed to resolve dependency: \(type)"
        }
    }
}

// MARK: - Dependency Injection Helper
extension Container {
    func safeResolve<Service>(_ serviceType: Service.Type) -> Service? {
        do {
            return try resolve(serviceType)
        } catch {
            SwiftyBeaver.error("Failed to resolve \(serviceType): \(error)")
            return nil
        }
    }
    
    func validateRegistration<Service>(_ serviceType: Service.Type) -> Bool {
        return safeResolve(serviceType) != nil
    }
}