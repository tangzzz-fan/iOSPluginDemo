//
//  HomeModule.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import Foundation
import Swinject

// MARK: - Home Module
class HomeModule: Module {
    let name = "Home"
    let coordinator: Coordinator
    private let container: Container
    
    init(container: Container) {
        self.container = container
        self.coordinator = HomeCoordinator(navigationController: UINavigationController(), container: container)
        registerDependencies(in: container)
    }
    
    func registerDependencies(in container: Container) {
        // 注册 Home 模块的依赖
        container.register(HomeViewModel.self) { _ in
            HomeViewModel()
        }.inObjectScope(.transient)
        
        container.register(HomeViewController.self) { resolver in
            let viewModel = resolver.resolve(HomeViewModel.self)!
            return HomeViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(HomeCoordinator.self) { resolver in
            let navigationController = UINavigationController()
            return HomeCoordinator(navigationController: navigationController, container: container)
        }.inObjectScope(.transient)
    }
} 