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
class MainCoordinator: NSObject, Coordinator, CoordinatorLifecycle {
    
    // MARK: - Properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let container: Container
    private let tabBarController: UITabBarController
    private var authCoordinator: AuthCoordinator?
    private let authStateManager = AuthStateManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
        self.tabBarController = UITabBarController()
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
        // 创建模态展示的认证协调器
        let authNavigationController = UINavigationController()
        authCoordinator = AuthCoordinator(navigationController: authNavigationController, container: container)
        addChildCoordinator(authCoordinator!)
        authCoordinator?.start()
        
        // 模态展示登录界面
        tabBarController.present(authNavigationController, animated: true)
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
        if let authCoordinator = self.authCoordinator {
            removeChildCoordinator(authCoordinator)
            self.authCoordinator = nil
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
        let profileCoordinator = ProfileCoordinator(navigationController: UINavigationController(), container: container)
        let settingsCoordinator = SettingsCoordinator(navigationController: UINavigationController(), container: container)
        
        // 添加子协调器
        addChildCoordinator(homeCoordinator)
        addChildCoordinator(profileCoordinator)
        addChildCoordinator(settingsCoordinator)
        
        // 设置标签栏项目
        homeCoordinator.start()
        profileCoordinator.start()
        settingsCoordinator.start()
        
        let homeTab = UITabBarItem(title: "首页", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        let profileTab = UITabBarItem(title: "个人", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        let settingsTab = UITabBarItem(title: "设置", image: UIImage(systemName: "gear"), selectedImage: UIImage(systemName: "gear"))
        
        homeCoordinator.navigationController.tabBarItem = homeTab
        profileCoordinator.navigationController.tabBarItem = profileTab
        settingsCoordinator.navigationController.tabBarItem = settingsTab
        
        tabBarController.viewControllers = [
            homeCoordinator.navigationController,
            profileCoordinator.navigationController,
            settingsCoordinator.navigationController
        ]
        
        tabBarController.selectedIndex = 0
    }
} 
