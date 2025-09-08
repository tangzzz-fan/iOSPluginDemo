//
//  DeviceControlCoordinator.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import UIKit
import Swinject

/// 设备控制协调器
class DeviceControlCoordinator: Coordinator, CoordinatorLifecycle, Loggable {
    // MARK: - Properties
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let container: Container
    
    // MARK: - Initialization
    
    init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
    }
    
    // MARK: - Coordinator Implementation
    
    func start() {
        log.info("设备控制协调器启动")
        
        // 解析视图控制器
        guard let viewController = container.resolve(DeviceControlViewController.self) else {
            log.error("无法解析设备控制视图控制器")
            return
        }
        
        // 设置导航控制器的根视图控制器
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func finish() {
        log.info("设备控制协调器结束")
        childCoordinators.removeAll()
    }
    
    // MARK: - Navigation Methods
    
    /// 导航到设备列表页面
    func navigateToDeviceList() {
        log.debug("导航到设备列表页面")
        // 在实际实现中，这里会导航到设备列表页面
    }
    
    /// 导航到设备详情页面
    /// - Parameter device: 设备信息
    func navigateToDeviceDetail(device: Device) {
        log.debug("导航到设备详情页面: \(device.name)")
        // 在实际实现中，这里会导航到设备详情页面
    }
    
    /// 导航到设备控制页面
    /// - Parameter device: 设备信息
    func navigateToDeviceControl(device: Device) {
        log.debug("导航到设备控制页面: \(device.name)")
        // 在实际实现中，这里会导航到设备控制页面
    }
}