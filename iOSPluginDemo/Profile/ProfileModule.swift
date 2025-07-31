//
//  ProfileModule.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import Foundation
import Swinject

class ProfileModule: Module {
    let name = "Profile"
    let coordinator: Coordinator
    private let container: Container
    
    init(container: Container) {
        self.container = container
        self.coordinator = ProfileCoordinator(navigationController: UINavigationController(), container: container)
        registerDependencies(in: container)
    }
    
    func registerDependencies(in container: Container) {
        // 注册 Profile 模块的依赖
        container.register(ProfileViewController.self) { _ in
            ProfileViewController()
        }.inObjectScope(.transient)
        
        container.register(ProfileCoordinator.self) { resolver in
            let navigationController = UINavigationController()
            return ProfileCoordinator(navigationController: navigationController, container: container)
        }.inObjectScope(.transient)
    }
} 