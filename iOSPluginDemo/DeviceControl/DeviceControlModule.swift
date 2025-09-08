//
//  DeviceControlModule.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import Foundation
import Swinject

/// 设备控制模块
class DeviceControlModule: Module, Loggable {
    let name = "DeviceControl"
    let coordinator: Coordinator
    private let container: Container
    
    init(container: Container) {
        self.container = container
        self.coordinator = DeviceControlCoordinator(
            navigationController: UINavigationController(), 
            container: container
        )
        registerDependencies(in: container)
    }
    
    func registerDependencies(in container: Container) {
        // 注册蓝牙连接服务
        container.register(BluetoothConnectionServiceProtocol.self) { _ in
            BluetoothConnectionService()
        }.inObjectScope(.container)
        
        // 注册设备控制服务
        container.register(BluetoothControlServiceProtocol.self) { resolver in
            let connectionService = resolver.resolve(BluetoothConnectionServiceProtocol.self)!
            return BluetoothControlService(connectionService: connectionService)
        }.inObjectScope(.container)
        
        container.register(MQTTControlServiceProtocol.self) { _ in
            MQTTControlService()
        }.inObjectScope(.container)
        
        container.register(MatterControlServiceProtocol.self) { _ in
            MatterControlService()
        }.inObjectScope(.container)
        
        // 注册设备连接管理器
        container.register(DeviceConnectionManagerProtocol.self) { resolver in
            let bluetoothConnectionService = resolver.resolve(BluetoothConnectionServiceProtocol.self)!
            let mqttService = resolver.resolve(MQTTControlServiceProtocol.self)!
            let matterService = resolver.resolve(MatterControlServiceProtocol.self)!
            return DeviceConnectionManager(
                bluetoothConnectionService: bluetoothConnectionService,
                mqttService: mqttService,
                matterService: matterService
            )
        }.inObjectScope(.container)
        
        // 注册设备命令服务
        container.register(DeviceCommandServiceProtocol.self) { resolver in
            let connectionManager = resolver.resolve(DeviceConnectionManagerProtocol.self)!
            let bluetoothService = resolver.resolve(BluetoothControlServiceProtocol.self)!
            let mqttService = resolver.resolve(MQTTControlServiceProtocol.self)!
            let matterService = resolver.resolve(MatterControlServiceProtocol.self)!
            return DeviceCommandService(
                connectionManager: connectionManager,
                bluetoothService: bluetoothService,
                mqttService: mqttService,
                matterService: matterService
            )
        }.inObjectScope(.container)
        
        // 注册状态管理器
        container.register(DeviceStateManagerProtocol.self) { _ in
            DeviceStateManager()
        }.inObjectScope(.container)
        
        // 注册视图模型
        container.register(DeviceControlViewModel.self) { resolver in
            let commandService = resolver.resolve(DeviceCommandServiceProtocol.self)!
            let stateManager = resolver.resolve(DeviceStateManagerProtocol.self)!
            return DeviceControlViewModel(
                commandService: commandService,
                stateManager: stateManager
            )
        }.inObjectScope(.transient)
        
        // 注册视图控制器
        container.register(DeviceControlViewController.self) { resolver in
            let viewModel = resolver.resolve(DeviceControlViewModel.self)!
            return DeviceControlViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        log.info("设备控制模块依赖注册完成")
    }
}