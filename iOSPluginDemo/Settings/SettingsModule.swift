//
//  SettingsModule.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import Foundation
import Swinject

class SettingsModule: Module {
    let name = "Settings"
    let coordinator: Coordinator
    private let container: Container
    
    init(container: Container) {
        self.container = container
        self.coordinator = SettingsCoordinator(navigationController: UINavigationController(), container: container)
        registerDependencies(in: container)
    }
    
    func registerDependencies(in container: Container) {
        // 注册 Settings 模块的依赖
        container.register(SettingsViewController.self) { _ in
            SettingsViewController()
        }.inObjectScope(.transient)
        
        container.register(SettingsCoordinator.self) { resolver in
            let navigationController = UINavigationController()
            return SettingsCoordinator(navigationController: navigationController, container: container)
        }.inObjectScope(.transient)
    }
} 