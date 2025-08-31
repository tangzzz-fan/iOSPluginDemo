//
//  DemoModule.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/1/27.
//

import Foundation
import Swinject

// MARK: - Demo Module
class DemoModule: Module {
    let name = "Demo"
    let coordinator: Coordinator
    private let container: Container
    
    init(container: Container) {
        self.container = container
        self.coordinator = DemoCoordinator(navigationController: UINavigationController(), container: container)
        registerDependencies(in: container)
    }
    
    func registerDependencies(in container: Container) {
        // 注册 Demo 模块的依赖
        container.register(DemoListViewModel.self) { _ in
            return DemoListViewModel()
        }.inObjectScope(.transient)
        
        container.register(DemoListViewController.self) { resolver in
            let viewModel = resolver.resolve(DemoListViewModel.self)!
            return DemoListViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(DemoCoordinator.self) { resolver in
            let navigationController = UINavigationController()
            return DemoCoordinator(navigationController: navigationController, container: container)
        }.inObjectScope(.transient)
        
        // 注册长截图相关服务和ViewModels
        registerScreenshotDependencies(in: container)
    }
    
    private func registerScreenshotDependencies(in container: Container) {
        // 注册截图服务
        container.register(ScreenshotGenerating.self) { _ in
            return ScreenshotGenerator()
        }.inObjectScope(.container)
        
        // 注册长截图演示ViewModel
        container.register(LongScreenshotDemoViewModel.self) { resolver in
            let screenshotService = resolver.resolve(ScreenshotGenerating.self)!
            return LongScreenshotDemoViewModel(screenshotService: screenshotService)
        }.inObjectScope(.transient)
        
        // 注册长截图演示ViewController
        container.register(LongScreenshotDemoViewController.self) { resolver in
            let viewModel = resolver.resolve(LongScreenshotDemoViewModel.self)!
            return LongScreenshotDemoViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
    }
}
