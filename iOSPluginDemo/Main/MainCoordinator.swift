//
//  MainCoordinator.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import UIKit
import Swinject
import SwiftyBeaver
import Combine

// MARK: - Main Coordinator
class MainCoordinator: NSObject, Coordinator, CoordinatorLifecycle, CoordinatorLifecycleManager {
    
    // MARK: - Properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let container: Container
    private let tabBarController: UITabBarController
    private let authStateManager = AuthStateManager.shared
    
    // MARK: - Coordinator Lifecycle Manager Properties
    var coordinatorStore: [String: Coordinator] = [:]
    
    // MARK: - Combine Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
        self.tabBarController = UITabBarController()
        super.init()
        setupNotifications()
    }
    
    init(tabBarController: UITabBarController, container: Container) {
        self.navigationController = UINavigationController()
        self.container = container
        self.tabBarController = tabBarController
        super.init()
        setupNotifications()
    }
    
    
    // MARK: - Coordinator
    func start() {
        // 默认显示主应用，然后根据登录状态决定是否需要弹出登录模块
        showMainApp()
        checkAuthStatusAndShowLoginIfNeeded()
    }
    
    func finish() {
        cleanupCoordinators()
        childCoordinators.removeAll()
    }
    
    // MARK: - Setup
    private func setupNotifications() {
        // 使用 Combine 监听认证事件
        authStateManager.authEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handleAuthEvent(event)
            }
            .store(in: &cancellables)
    }
    
    private func checkAuthStatusAndShowLoginIfNeeded() {
        // 检查用户是否已登录
        if !authStateManager.isUserLoggedIn() {
            // 用户未登录，延迟一点时间后弹出登录模块
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showAuthFlow()
            }
        }
    }
    
    private func showAuthFlow() {
        // 使用改进的生命周期管理创建认证协调器
        let authCoordinator = createCoordinator(
            type: AuthCoordinator.self,
            identifier: "auth"
        ) {
            let authNavigationController = UINavigationController()
            return AuthCoordinator(navigationController: authNavigationController, container: self.container)
        }
        
        addChildCoordinator(authCoordinator)
        authCoordinator.start()
        
        // 模态展示登录界面
        tabBarController.present(authCoordinator.navigationController, animated: true)
    }
    
    private func showMainApp() {
        setupTabBarController()
        // 直接设置 tabBarController 为根视图控制器，避免嵌套导航控制器
        navigationController.setViewControllers([tabBarController], animated: false)
        // 隐藏主导航控制器的导航栏，因为每个标签页都有自己的导航控制器
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    private func handleAuthEvent(_ event: AuthEvent) {
        switch event {
        case .loginSuccess(let user):
            SwiftyBeaver.self.info("登录成功: \(user.email)，关闭认证界面")
            handleLoginSuccess()
            
        case .logout:
            SwiftyBeaver.self.info("用户退出登录，显示登录界面")
            handleUserLogout()
            
        case .authRequired:
            SwiftyBeaver.self.info("需要认证，显示登录界面")
            showAuthFlow()
            
        case .loginFailed(let error):
            SwiftyBeaver.self.error("登录失败: \(error.localizedDescription)")
        }
    }
    
    private func handleLoginSuccess() {
        // 移除认证协调器
        if let authCoordinator = getCoordinator(type: AuthCoordinator.self, identifier: "auth") {
            removeChildCoordinator(authCoordinator)
            removeCoordinator(identifier: "auth")
        }
        
        // 关闭登录模态界面
        tabBarController.dismiss(animated: true) {
            // 登录完成后可以在这里执行一些额外的操作
            // 比如刷新用户数据、更新UI等
        }
    }
    
    private func handleUserLogout() {
        // 显示登录界面
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showAuthFlow()
        }
    }
    
    // MARK: - Tab Bar Setup
    private func setupTabBarController() {
        let homeCoordinator = HomeCoordinator(navigationController: UINavigationController(), container: container)
        let demoCoordinator = DemoCoordinator(navigationController: UINavigationController(), container: container)
        let profileCoordinator = ProfileCoordinator(navigationController: UINavigationController(), container: container)
        let settingsCoordinator = SettingsCoordinator(navigationController: UINavigationController(), container: container)
        
        // 添加子协调器
        addChildCoordinator(homeCoordinator)
        addChildCoordinator(demoCoordinator)
        addChildCoordinator(profileCoordinator)
        addChildCoordinator(settingsCoordinator)
        
        // 设置标签栏项目
        homeCoordinator.start()
        demoCoordinator.start()
        profileCoordinator.start()
        settingsCoordinator.start()
        
        let homeTab = UITabBarItem(title: "首页", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        let demoTab = UITabBarItem(title: "演示", image: UIImage(systemName: "play.rectangle"), selectedImage: UIImage(systemName: "play.rectangle.fill"))
        let profileTab = UITabBarItem(title: "个人", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        let settingsTab = UITabBarItem(title: "设置", image: UIImage(systemName: "gear"), selectedImage: UIImage(systemName: "gear"))
        
        homeCoordinator.navigationController.tabBarItem = homeTab
        demoCoordinator.navigationController.tabBarItem = demoTab
        profileCoordinator.navigationController.tabBarItem = profileTab
        settingsCoordinator.navigationController.tabBarItem = settingsTab
        
        tabBarController.viewControllers = [
            homeCoordinator.navigationController,
            demoCoordinator.navigationController,
            profileCoordinator.navigationController,
            settingsCoordinator.navigationController
        ]
        
        tabBarController.selectedIndex = 0
    }
}

// MARK: - Enhanced Coordinator Lifecycle Management
extension MainCoordinator {
    
    func createCoordinator<T: Coordinator>(
        type: T.Type,
        identifier: String,
        factory: () -> T
    ) -> T {
        // 检查是否已存在同一标识符的 Coordinator
        if let existingCoordinator = coordinatorStore[identifier] as? T {
            SwiftyBeaver.warning("重用已存在的协调器: \(identifier)")
            return existingCoordinator
        }
        
        // 创建新的 Coordinator
        let coordinator = factory()
        coordinatorStore[identifier] = coordinator
        
        SwiftyBeaver.info("创建新协调器: \(identifier)")
        return coordinator
    }
    
    func getCoordinator<T: Coordinator>(type: T.Type, identifier: String) -> T? {
        return coordinatorStore[identifier] as? T
    }
    
    func removeCoordinator(identifier: String) {
        if let coordinator = coordinatorStore[identifier] {
            coordinator.finish()
            coordinatorStore.removeValue(forKey: identifier)
            SwiftyBeaver.info("移除协调器: \(identifier)")
        }
    }
    
    func cleanupCoordinators() {
        SwiftyBeaver.info("清理所有子协调器")
        
        for (identifier, coordinator) in coordinatorStore {
            coordinator.finish()
            SwiftyBeaver.info("清理协调器: \(identifier)")
        }
        
        coordinatorStore.removeAll()
        cancellables.removeAll()
    }
}

// MARK: - CoordinatorLifecycleManager Protocol Implementation
extension MainCoordinator {
    
    func createCoordinator<T: Coordinator>(_ type: T.Type, with container: Container) -> T {
        // 根据类型创建对应的 Coordinator
        switch type {
        case is AuthCoordinator.Type:
            let navigationController = UINavigationController()
            return AuthCoordinator(navigationController: navigationController, container: container) as! T
            
        case is HomeCoordinator.Type:
            let navigationController = UINavigationController()
            return HomeCoordinator(navigationController: navigationController, container: container) as! T
            
        case is ProfileCoordinator.Type:
            let navigationController = UINavigationController()
            return ProfileCoordinator(navigationController: navigationController, container: container) as! T
            
        case is SettingsCoordinator.Type:
            let navigationController = UINavigationController()
            return SettingsCoordinator(navigationController: navigationController, container: container) as! T
            
        case is DemoCoordinator.Type:
            let navigationController = UINavigationController()
            return DemoCoordinator(navigationController: navigationController, container: container) as! T
            
        default:
            fatalError("Unsupported coordinator type: \(type)")
        }
    }
    
    func retainCoordinator(_ coordinator: Coordinator) {
        // 添加到子协调器列表
        if !childCoordinators.contains(where: { ObjectIdentifier($0) == ObjectIdentifier(coordinator) }) {
            childCoordinators.append(coordinator)
            SwiftyBeaver.info("Retained coordinator: \(type(of: coordinator))")
        }
    }
    
    func releaseCoordinator(_ coordinator: Coordinator) {
        // 从子协调器列表中移除
        childCoordinators.removeAll { ObjectIdentifier($0) == ObjectIdentifier(coordinator) }
        SwiftyBeaver.info("Released coordinator: \(type(of: coordinator))")
    }
    
    func cleanupAllCoordinators() {
        // 清理所有子协调器
        cleanupCoordinators()
        childCoordinators.removeAll()
    }
    
    func getActiveCoordinators() -> [Coordinator] {
        return childCoordinators
    }
    
    func isCoordinatorActive(_ coordinator: Coordinator) -> Bool {
        return childCoordinators.contains { ObjectIdentifier($0) == ObjectIdentifier(coordinator) }
    }
} 
