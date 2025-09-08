//
//  DeviceProvisioningModule.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import Foundation
import Swinject

/// 设备配网模块
class DeviceProvisioningModule: Module {
    let name = "DeviceProvisioning"
    let coordinator: Coordinator
    private let container: Container
    
    init(container: Container) {
        self.container = container
        self.coordinator = DeviceProvisioningCoordinator(
            navigationController: UINavigationController(), 
            container: container
        )
        registerDependencies(in: container)
    }
    
    func registerDependencies(in container: Container) {
        // 注册状态机
        container.register(ProvisioningStateMachineProtocol.self) { _ in
            ProvisioningStateMachine()
        }.inObjectScope(.transient)
        
        // 注册配网服务
        container.register(BluetoothProvisioningServiceProtocol.self) { _ in
            BluetoothProvisioningService()
        }.inObjectScope(.container)
        
        container.register(WiFiProvisioningServiceProtocol.self) { _ in
            WiFiProvisioningService()
        }.inObjectScope(.container)
        
        container.register(QRCodeProvisioningServiceProtocol.self) { _ in
            QRCodeProvisioningService()
        }.inObjectScope(.container)
        
        // 注册视图模型
        container.register(DeviceProvisioningViewModel.self) { resolver in
            let stateMachine = resolver.resolve(ProvisioningStateMachineProtocol.self)!
            let bluetoothService = resolver.resolve(BluetoothProvisioningServiceProtocol.self)!
            let wifiService = resolver.resolve(WiFiProvisioningServiceProtocol.self)!
            let qrCodeService = resolver.resolve(QRCodeProvisioningServiceProtocol.self)!
            
            return DeviceProvisioningViewModel(
                stateMachine: stateMachine,
                bluetoothService: bluetoothService,
                wifiService: wifiService,
                qrCodeService: qrCodeService
            )
        }.inObjectScope(.transient)
        
        // 注册视图控制器
        container.register(DeviceProvisioningViewController.self) { resolver in
            let viewModel = resolver.resolve(DeviceProvisioningViewModel.self)!
            return DeviceProvisioningViewController(viewModel: viewModel)
        }.inObjectScope(.transient)

    }
}
