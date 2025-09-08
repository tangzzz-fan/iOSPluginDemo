//
//  DeviceProvisioningCoordinator.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import UIKit
import Swinject

/// 设备配网协调器
class DeviceProvisioningCoordinator: Coordinator, CoordinatorLifecycle, Loggable {
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
        log.info("设备配网协调器启动")
        
        // 解析视图控制器
        guard let viewController = container.resolve(DeviceProvisioningViewController.self) else {
            AppLogger.error("无法解析设备配网视图控制器")
            return
        }
        
        // 设置导航控制器的根视图控制器
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func finish() {
        log.info("设备配网协调器结束")
        childCoordinators.removeAll()
    }
    
    // MARK: - Navigation Methods
    
    /// 导航到配网成功页面
    func navigateToSuccess() {
        log.debug("导航到配网成功页面")
        // 在实际实现中，这里会导航到配网成功页面
    }
    
    /// 导航到配网失败页面
    /// - Parameter error: 错误信息
    func navigateToFailure(error: Error) {
        log.debug("导航到配网失败页面，错误: \(error.localizedDescription)")
        // 在实际实现中，这里会导航到配网失败页面
    }
    
    /// 导航到设备列表页面
    func navigateToDeviceList() {
        log.debug("导航到设备列表页面")
        // 在实际实现中，这里会导航到设备列表页面
    }
    
    /// 导航到网络列表页面
    func navigateToNetworkList() {
        log.debug("导航到网络列表页面")
        // 在实际实现中，这里会导航到网络列表页面
    }
    
    /// 导航到二维码扫描页面
    func navigateToQRCodeScanner() {
        log.debug("导航到二维码扫描页面")
        // 在实际实现中，这里会导航到二维码扫描页面
    }
}
