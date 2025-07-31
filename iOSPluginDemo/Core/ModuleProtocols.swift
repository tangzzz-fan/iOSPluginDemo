//
//  ModuleProtocols.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import Foundation
import Swinject

// MARK: - Module Protocol
protocol Module {
    var name: String { get }
    var coordinator: Coordinator { get }
    func registerDependencies(in container: Container)
}

// MARK: - Module Factory
protocol ModuleFactory {
    func createModule(for type: ModuleType) -> Module
}

enum ModuleType: String, CaseIterable {
    case home = "Home"
    case profile = "Profile"
    case settings = "Settings"
    case auth = "Auth"
    // 添加更多模块类型
}

// MARK: - Module Coordinator
protocol ModuleCoordinator: Coordinator {
    var moduleType: ModuleType { get }
    var container: Container { get }
}

// MARK: - Module View Controller Factory
protocol ModuleViewControllerFactory {
    func makeViewController(for type: ViewControllerType) -> UIViewController
}

enum ViewControllerType {
    case home
    case profile
    case settings
    case auth
    case forgotPassword
    case registration
    // 添加更多视图控制器类型
}

// MARK: - Module View Model Factory
protocol ModuleViewModelFactory {
    func makeViewModel(for type: ViewModelType) -> ViewModelable
}

enum ViewModelType {
    case home
    case profile
    case settings
    // 添加更多视图模型类型
} 