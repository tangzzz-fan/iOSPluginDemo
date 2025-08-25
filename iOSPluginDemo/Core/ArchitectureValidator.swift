//
//  ArchitectureValidator.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import Foundation
import SwiftyBeaver

// MARK: - Architecture Validator
class ArchitectureValidator {
    
    private let log = SwiftyBeaver.self
    
    static func validate() {
        let validator = ArchitectureValidator()
        validator.validateDIContainer()
        validator.validateModules()
        validator.validateCoordinators()
        validator.log.info("Architecture validation completed")
    }
    
    private func validateDIContainer() {
        log.info("Validating DI Container...")
        
        let container = DIContainerManagerImpl.shared.container
        
        // 验证核心依赖
        let coordinatorFactory = container.resolve(CoordinatorFactory.self)
        log.info("CoordinatorFactory resolved: \(coordinatorFactory != nil)")
        
        let moduleFactory = container.resolve(ModuleFactory.self)
        log.info("ModuleFactory resolved: \(moduleFactory != nil)")
        
        // 验证模块依赖
        let homeService = container.resolve(HomeServiceProtocol.self)
        log.info("HomeService resolved: \(homeService != nil)")
    }
    
    private func validateModules() {
        log.info("Validating Modules...")
        
        let container = DIContainerManagerImpl.shared.container
        let moduleFactory = container.resolve(ModuleFactory.self)!
        
        // 验证所有模块类型
        for moduleType in ModuleType.allCases {
            let module = moduleFactory.createModule(for: moduleType)
            log.info("Module \(module.name) created successfully")
        }
    }
    
    private func validateCoordinators() {
        log.info("Validating Coordinators...")
        
        let container = DIContainerManagerImpl.shared.container
        
        // 验证协调器工厂
        let coordinatorFactory = container.resolve(CoordinatorFactory.self)
        log.info("CoordinatorFactory resolved: \(coordinatorFactory != nil)")
        
        // 验证具体的协调器实例
        let mainCoordinator = container.resolve(MainCoordinator.self)
        log.info("MainCoordinator resolved: \(mainCoordinator != nil)")
        
        let authCoordinator = container.resolve(AuthCoordinator.self)
        log.info("AuthCoordinator resolved: \(authCoordinator != nil)")
    }
} 
