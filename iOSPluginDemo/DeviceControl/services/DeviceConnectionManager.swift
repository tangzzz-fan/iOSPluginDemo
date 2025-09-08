//
//  DeviceConnectionManager.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import Foundation
import Combine

/// 设备连接管理器协议
protocol DeviceConnectionManagerProtocol: AnyObject {
    /// 连接设备
    /// - Parameter device: 要连接的设备
    /// - Returns: 用于接收连接结果的Publisher
    func connect(to device: Device) -> AnyPublisher<Bool, Error>
    
    /// 断开设备连接
    /// - Parameter device: 要断开连接的设备
    /// - Returns: 用于接收断开结果的Publisher
    func disconnect(from device: Device) -> AnyPublisher<Bool, Error>
    
    /// 检查设备是否已连接
    /// - Parameter device: 设备
    /// - Returns: 设备是否已连接
    func isConnected(to device: Device) -> Bool
    
    /// 获取设备连接状态
    /// - Parameter device: 设备
    /// - Returns: 设备连接状态的Publisher
    func getConnectionStatus(for device: Device) -> AnyPublisher<Bool, Error>
}

/// 设备连接管理器实现
class DeviceConnectionManager: DeviceConnectionManagerProtocol, Loggable {
    // MARK: - Properties
    
    private let bluetoothConnectionService: BluetoothConnectionServiceProtocol
    private let mqttService: MQTTControlServiceProtocol
    private let matterService: MatterControlServiceProtocol
    
    // 设备连接状态映射
    private var deviceConnectionStatus: [String: Bool] = [:]
    
    // Publisher subjects for events
    private let connectionStatusSubject = CurrentValueSubject<[String: Bool], Error>([:])
    
    // MARK: - Initialization
    
    init(bluetoothConnectionService: BluetoothConnectionServiceProtocol, 
         mqttService: MQTTControlServiceProtocol,
         matterService: MatterControlServiceProtocol) {
        self.bluetoothConnectionService = bluetoothConnectionService
        self.mqttService = mqttService
        self.matterService = matterService
        log.debug("设备连接管理器初始化完成")
    }
    
    // MARK: - DeviceConnectionManagerProtocol Implementation
    
    /// 连接设备
    /// - Parameter device: 要连接的设备
    /// - Returns: 用于接收连接结果的Publisher
    func connect(to device: Device) -> AnyPublisher<Bool, Error> {
        log.debug("连接设备: \(device.name), 连接方式: \(device.connectionType)")
        
        switch device.connectionType {
        case .bluetooth:
            return connectViaBluetooth(device: device)
        case .wifi, .mqtt:
            return connectViaMQTT(device: device)
        case .matter:
            return connectViaMatter(device: device)
        case .cloud:
            return connectViaCloud(device: device)
        }
    }
    
    /// 断开设备连接
    /// - Parameter device: 要断开连接的设备
    /// - Returns: 用于接收断开结果的Publisher
    func disconnect(from device: Device) -> AnyPublisher<Bool, Error> {
        log.debug("断开设备连接: \(device.name), 连接方式: \(device.connectionType)")
        
        switch device.connectionType {
        case .bluetooth:
            return disconnectViaBluetooth(device: device)
        case .wifi, .mqtt:
            return disconnectViaMQTT(device: device)
        case .matter:
            return disconnectViaMatter(device: device)
        case .cloud:
            return disconnectViaCloud(device: device)
        }
    }
    
    /// 检查设备是否已连接
    /// - Parameter device: 设备
    /// - Returns: 设备是否已连接
    func isConnected(to device: Device) -> Bool {
        return deviceConnectionStatus[device.id] ?? false
    }
    
    /// 获取设备连接状态
    /// - Parameter device: 设备
    /// - Returns: 设备连接状态的Publisher
    func getConnectionStatus(for device: Device) -> AnyPublisher<Bool, Error> {
        log.debug("获取设备连接状态: \(device.name)")
        
        // 返回当前连接状态
        return Just(deviceConnectionStatus[device.id] ?? false)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    /// 通过蓝牙连接设备
    /// - Parameter device: 设备
    /// - Returns: 用于接收连接结果的Publisher
    private func connectViaBluetooth(device: Device) -> AnyPublisher<Bool, Error> {
        return bluetoothConnectionService.connect(to: device)
            .handleEvents(receiveOutput: { [weak self] isConnected in
                self?.updateConnectionStatus(for: device, isConnected: isConnected)
            })
            .eraseToAnyPublisher()
    }
    
    /// 通过蓝牙断开设备连接
    /// - Parameter device: 设备
    /// - Returns: 用于接收断开结果的Publisher
    private func disconnectViaBluetooth(device: Device) -> AnyPublisher<Bool, Error> {
        return bluetoothConnectionService.disconnect(from: device)
            .handleEvents(receiveOutput: { [weak self] isDisconnected in
                if isDisconnected {
                    self?.updateConnectionStatus(for: device, isConnected: false)
                }
            })
            .eraseToAnyPublisher()
    }
    
    /// 通过MQTT连接设备
    /// - Parameter device: 设备
    /// - Returns: 用于接收连接结果的Publisher
    private func connectViaMQTT(device: Device) -> AnyPublisher<Bool, Error> {
        // 在实际实现中，这里会根据设备信息连接到MQTT服务器
        // 并订阅设备相关的主题
        
        // 模拟连接过程
        return Future<Bool, Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                // 模拟连接成功
                self.updateConnectionStatus(for: device, isConnected: true)
                self.log.info("MQTT连接设备成功: \(device.name)")
                promise(.success(true))
            }
        }
        .timeout(.seconds(10), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    /// 通过MQTT断开设备连接
    /// - Parameter device: 设备
    /// - Returns: 用于接收断开结果的Publisher
    private func disconnectViaMQTT(device: Device) -> AnyPublisher<Bool, Error> {
        // 在实际实现中，这里会取消订阅设备相关的主题
        // 并断开MQTT服务器连接（如果不再需要）
        
        // 模拟断开过程
        return Future<Bool, Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                // 模拟断开成功
                self.updateConnectionStatus(for: device, isConnected: false)
                self.log.info("MQTT断开设备连接成功: \(device.name)")
                promise(.success(true))
            }
        }
        .timeout(.seconds(5), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    /// 通过Matter连接设备
    /// - Parameter device: 设备
    /// - Returns: 用于接收连接结果的Publisher
    private func connectViaMatter(device: Device) -> AnyPublisher<Bool, Error> {
        // Matter设备通常通过配对方式进行连接
        
        // 模拟连接过程
        return Future<Bool, Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                // 模拟连接成功
                self.updateConnectionStatus(for: device, isConnected: true)
                self.log.info("Matter连接设备成功: \(device.name)")
                promise(.success(true))
            }
        }
        .timeout(.seconds(10), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    /// 通过Matter断开设备连接
    /// - Parameter device: 设备
    /// - Returns: 用于接收断开结果的Publisher
    private func disconnectViaMatter(device: Device) -> AnyPublisher<Bool, Error> {
        // Matter设备通过解除配对方式断开连接
        
        // 模拟断开过程
        return Future<Bool, Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                // 模拟断开成功
                self.updateConnectionStatus(for: device, isConnected: false)
                self.log.info("Matter断开设备连接成功: \(device.name)")
                promise(.success(true))
            }
        }
        .timeout(.seconds(5), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    /// 通过云端连接设备
    /// - Parameter device: 设备
    /// - Returns: 用于接收连接结果的Publisher
    private func connectViaCloud(device: Device) -> AnyPublisher<Bool, Error> {
        // 在实际实现中，这里会通过云端API连接设备
        
        // 模拟连接过程
        return Future<Bool, Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
                // 模拟连接成功
                self.updateConnectionStatus(for: device, isConnected: true)
                self.log.info("云端连接设备成功: \(device.name)")
                promise(.success(true))
            }
        }
        .timeout(.seconds(15), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    /// 通过云端断开设备连接
    /// - Parameter device: 设备
    /// - Returns: 用于接收断开结果的Publisher
    private func disconnectViaCloud(device: Device) -> AnyPublisher<Bool, Error> {
        // 在实际实现中，这里会通过云端API断开设备连接
        
        // 模拟断开过程
        return Future<Bool, Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                // 模拟断开成功
                self.updateConnectionStatus(for: device, isConnected: false)
                self.log.info("云端断开设备连接成功: \(device.name)")
                promise(.success(true))
            }
        }
        .timeout(.seconds(10), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    /// 更新设备连接状态
    /// - Parameters:
    ///   - device: 设备
    ///   - isConnected: 是否已连接
    private func updateConnectionStatus(for device: Device, isConnected: Bool) {
        deviceConnectionStatus[device.id] = isConnected
        connectionStatusSubject.send(deviceConnectionStatus)
        log.debug("设备连接状态更新: \(device.name) -> \(isConnected)")
    }
}