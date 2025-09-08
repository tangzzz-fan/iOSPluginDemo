//
//  DeviceCommandService.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import Foundation
import Combine

/// 设备命令服务协议
protocol DeviceCommandServiceProtocol: AnyObject {
    /// 发送控制命令到设备
    /// - Parameter command: 控制命令
    /// - Returns: 用于接收发送结果的Publisher
    func sendCommand(_ command: ControlCommand) -> AnyPublisher<Bool, Error>
    
    /// 发送控制命令到设备并等待响应
    /// - Parameter command: 控制命令
    /// - Returns: 用于接收设备响应的Publisher
    func sendCommandAndWaitForResponse(_ command: ControlCommand) -> AnyPublisher<[String: Any], Error>
    
    /// 批量发送控制命令
    /// - Parameter commands: 控制命令数组
    /// - Returns: 用于接收发送结果的Publisher
    func sendCommands(_ commands: [ControlCommand]) -> AnyPublisher<[Bool], Error>
    
    /// 取消当前正在进行的命令
    func cancelCurrentCommand()
}

/// 设备命令服务实现
class DeviceCommandService: DeviceCommandServiceProtocol, Loggable {
    // MARK: - Properties
    
    private let connectionManager: DeviceConnectionManagerProtocol
    private let bluetoothService: BluetoothControlServiceProtocol
    private let mqttService: MQTTControlServiceProtocol
    private let matterService: MatterControlServiceProtocol
    
    // 当前命令的Cancellable
    private var currentCommandCancellable: AnyCancellable?
    
    // 命令队列
    private var commandQueue: [ControlCommand] = []
    private let commandQueueSubject = PassthroughSubject<ControlCommand, Never>()
    
    // MARK: - Initialization
    
    init(connectionManager: DeviceConnectionManagerProtocol,
         bluetoothService: BluetoothControlServiceProtocol,
         mqttService: MQTTControlServiceProtocol,
         matterService: MatterControlServiceProtocol) {
        self.connectionManager = connectionManager
        self.bluetoothService = bluetoothService
        self.mqttService = mqttService
        self.matterService = matterService
        log.debug("设备命令服务初始化完成")
    }
    
    // MARK: - DeviceCommandServiceProtocol Implementation
    
    /// 发送控制命令到设备
    /// - Parameter command: 控制命令
    /// - Returns: 用于接收发送结果的Publisher
    func sendCommand(_ command: ControlCommand) -> AnyPublisher<Bool, Error> {
        log.debug("发送控制命令: \(command.type) 到设备ID: \(command.deviceId)")
        
        // 创建设备对象（简化处理，实际应该从设备管理器获取）
        let device = Device(
            id: command.deviceId,
            name: "Device-\(command.deviceId)",
            type: .vacuumCleaner,
            connectionType: .bluetooth
        )
        
        // 检查设备连接状态
        if !connectionManager.isConnected(to: device) {
            log.warning("设备未连接，无法发送命令: \(command.type)")
            return Fail(error: DeviceCommandError.deviceNotConnected)
                .eraseToAnyPublisher()
        }
        
        // 根据连接方式发送命令
        switch device.connectionType {
        case .bluetooth:
            return bluetoothService.sendCommand(command, to: device)
        case .wifi, .mqtt:
            // 构造MQTT主题和消息
            let topic = "devices/\(device.id)/commands"
            let message = encodeCommandToJSON(command)
            return mqttService.publish(to: topic, message: message)
        case .matter:
            return matterService.sendCommand(command, to: device)
        case .cloud:
            return sendCommandViaCloud(command: command)
        }
    }
    
    /// 发送控制命令到设备并等待响应
    /// - Parameter command: 控制命令
    /// - Returns: 用于接收设备响应的Publisher
    func sendCommandAndWaitForResponse(_ command: ControlCommand) -> AnyPublisher<[String: Any], Error> {
        log.debug("发送控制命令并等待响应: \(command.type) 到设备ID: \(command.deviceId)")
        
        // 在实际实现中，这里会发送命令并等待设备响应
        // 可能需要订阅特定的主题或特征来接收响应
        
        // 模拟响应过程
        return Future<[String: Any], Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
                // 模拟设备响应
                let response: [String: Any] = [
                    "commandId": command.id,
                    "deviceId": command.deviceId,
                    "status": "success",
                    "data": ["batteryLevel": 80, "cleaningMode": "auto"]
                ]
                self.log.info("收到设备响应: \(response)")
                promise(.success(response))
            }
        }
        .timeout(.seconds(30), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    /// 批量发送控制命令
    /// - Parameter commands: 控制命令数组
    /// - Returns: 用于接收发送结果的Publisher
    func sendCommands(_ commands: [ControlCommand]) -> AnyPublisher<[Bool], Error> {
        log.debug("批量发送控制命令，数量: \(commands.count)")
        
        // 创建结果数组
        let results: [Bool] = []
        let resultsSubject = PassthroughSubject<Bool, Error>()
        let completionSubject = PassthroughSubject<[Bool], Error>()
        
        // 串行发送命令
        sendNextCommand(commands, results: results, resultsSubject: resultsSubject, completionSubject: completionSubject)
        
        return completionSubject
            .timeout(.seconds(60), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// 取消当前正在进行的命令
    func cancelCurrentCommand() {
        log.debug("取消当前正在进行的命令")
        currentCommandCancellable?.cancel()
        currentCommandCancellable = nil
    }
    
    // MARK: - Private Methods
    
    /// 发送下一个命令
    /// - Parameters:
    ///   - commands: 命令数组
    ///   - results: 结果数组
    ///   - resultsSubject: 结果Subject
    ///   - completionSubject: 完成Subject
    private func sendNextCommand(_ commands: [ControlCommand], results: [Bool], resultsSubject: PassthroughSubject<Bool, Error>, completionSubject: PassthroughSubject<[Bool], Error>) {
        guard !commands.isEmpty else {
            // 所有命令发送完成
            completionSubject.send(results)
            completionSubject.send(completion: .finished)
            return
        }
        
        // 取出第一个命令
        var mutableCommands = commands
        var mutableResults = results
        let command = mutableCommands.removeFirst()
        
        // 发送命令
        currentCommandCancellable = sendCommand(command)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    resultsSubject.send(completion: .failure(error))
                }
            }, receiveValue: { success in
                mutableResults.append(success)
                // 发送下一个命令
                self.sendNextCommand(mutableCommands, results: mutableResults, resultsSubject: resultsSubject, completionSubject: completionSubject)
            })
    }
    
    /// 通过云端发送命令
    /// - Parameter command: 控制命令
    /// - Returns: 用于接收发送结果的Publisher
    private func sendCommandViaCloud(command: ControlCommand) -> AnyPublisher<Bool, Error> {
        // 在实际实现中，这里会通过云端API发送命令
        
        // 模拟发送过程
        return Future<Bool, Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
                // 模拟发送成功
                self.log.info("云端命令发送成功: \(command.type)")
                promise(.success(true))
            }
        }
        .timeout(.seconds(15), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    /// 将命令编码为JSON字符串
    /// - Parameter command: 控制命令
    /// - Returns: JSON字符串
    private func encodeCommandToJSON(_ command: ControlCommand) -> String {
        // 在实际实现中，这里会将命令对象序列化为JSON
        
        // 简化处理，返回模拟的JSON字符串
        return """
        {
            "commandId": "\(command.id)",
            "deviceId": "\(command.deviceId)",
            "type": "\(command.type.rawValue)",
            "timestamp": "\(command.timestamp.timeIntervalSince1970)"
        }
        """
    }
}

// MARK: - Device Command Errors

enum DeviceCommandError: Error, LocalizedError {
    case deviceNotConnected
    case commandSendFailed(String)
    case responseTimeout
    
    var errorDescription: String? {
        switch self {
        case .deviceNotConnected:
            return "设备未连接"
        case .commandSendFailed(let message):
            return "命令发送失败: \(message)"
        case .responseTimeout:
            return "设备响应超时"
        }
    }
}