//
//  ProvisioningStateMachine.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import Foundation
import Combine

/// 配网状态机实现
class ProvisioningStateMachine: ProvisioningStateMachineProtocol {
    // MARK: - Properties
    
    /// 当前状态
    private(set) var currentState: ProvisioningState {
        didSet {
            // 当状态改变时，调用回调闭包
            onStateChanged?(currentState)
        }
    }
    
    /// 状态变化回调闭包
    var onStateChanged: ((ProvisioningState) -> Void)?
    
    /// 状态转换映射表
    private var transitions: [ProvisioningStateType: [ProvisioningEvent: ProvisioningStateType]] = [:]
    
    /// 当前配网设备
    private var currentDevice: ProvisioningDevice?
    
    /// 当前网络信息
    private var currentNetwork: NetworkInfo?
    
    // MARK: - Initialization
    
    init() {
        // 初始化为Idle状态
        self.currentState = ProvisioningState(
            type: .idle,
            description: "初始状态"
        )
        
        // 设置状态转换规则
        setupTransitions()
        
        log.debug("配网状态机初始化完成")
    }
    
    // MARK: - State Transition Management
    
    /// 设置状态转换规则
    private func setupTransitions() {
        // Idle状态转换
        transitions[.idle] = [
            .startProvisioning: .selectingMethod
        ]
        
        // SelectingMethod状态转换
        transitions[.selectingMethod] = [
            .selectBluetoothMethod: .bluetoothScanning,
            .selectWiFiMethod: .wifiScanning,
            .selectQRCodeMethod: .qrCodeScanning,
            .cancel: .idle
        ]
        
        // BluetoothScanning状态转换
        transitions[.bluetoothScanning] = [
            // 使用带默认参数的事件作为键
            .deviceFound(ProvisioningDevice(id: "", name: "", type: .other)): .bluetoothConnecting,
            .cancel: .selectingMethod
        ]
        
        // BluetoothConnecting状态转换
        transitions[.bluetoothConnecting] = [
            .deviceConnected: .bluetoothProvisioning,
            // 使用带默认参数的事件作为键
            .provisioningFailed(NSError(domain: "", code: 0, userInfo: nil)): .failed,
            .cancel: .selectingMethod
        ]
        
        // BluetoothProvisioning状态转换
        transitions[.bluetoothProvisioning] = [
            // 使用带默认参数的事件作为键
            .provisioningProgress(0.0): .provisioning,
            // 使用带默认参数的事件作为键
            .provisioningFailed(NSError(domain: "", code: 0, userInfo: nil)): .failed,
            .cancel: .selectingMethod
        ]
        
        // WiFiScanning状态转换
        transitions[.wifiScanning] = [
            // 使用带默认参数的事件作为键
            .networkSelected(""): .wifiConnecting,
            .cancel: .selectingMethod
        ]
        
        // WiFiConnecting状态转换
        transitions[.wifiConnecting] = [
            .deviceConnected: .wifiProvisioning,
            // 使用带默认参数的事件作为键
            .provisioningFailed(NSError(domain: "", code: 0, userInfo: nil)): .failed,
            .cancel: .selectingMethod
        ]
        
        // WiFiProvisioning状态转换
        transitions[.wifiProvisioning] = [
            // 使用带默认参数的事件作为键
            .provisioningProgress(0.0): .provisioning,
            // 使用带默认参数的事件作为键
            .provisioningFailed(NSError(domain: "", code: 0, userInfo: nil)): .failed,
            .cancel: .selectingMethod
        ]
        
        // QRCodeScanning状态转换
        transitions[.qrCodeScanning] = [
            // 使用带默认参数的事件作为键
            .qrCodeScanned(""): .qrCodeProcessing,
            .cancel: .selectingMethod
        ]
        
        // QRCodeProcessing状态转换
        transitions[.qrCodeProcessing] = [
            // 使用带默认参数的事件作为键
            .provisioningProgress(0.0): .provisioning,
            // 使用带默认参数的事件作为键
            .provisioningFailed(NSError(domain: "", code: 0, userInfo: nil)): .failed,
            .cancel: .selectingMethod
        ]
        
        // Provisioning状态转换
        transitions[.provisioning] = [
            // 使用带默认参数的事件作为键
            .provisioningProgress(0.0): .provisioning,
            .provisioningSuccess: .success,
            // 使用带默认参数的事件作为键
            .provisioningFailed(NSError(domain: "", code: 0, userInfo: nil)): .failed,
            .cancel: .selectingMethod
        ]
        
        // Success状态转换
        transitions[.success] = [
            .finish: .completed
        ]
        
        // Failed状态转换
        transitions[.failed] = [
            .retry: .selectingMethod,
            .cancel: .selectingMethod
        ]
        
        // Completed状态转换
        transitions[.completed] = [:]
        
        log.debug("状态转换规则设置完成")
    }
    
    /// 检查是否可以从当前状态转换到目标状态
    /// - Parameter event: 触发转换的事件
    /// - Returns: 是否可以转换
    private func canTransition(with event: ProvisioningEvent) -> Bool {
        guard let targetState = transitions[currentState.type]?[event] else {
            return false
        }
        
        // 检查目标状态是否存在
        return ProvisioningStateType.allCases.contains(targetState)
    }
    
    /// 获取事件对应的目标状态
    /// - Parameter event: 触发转换的事件
    /// - Returns: 目标状态类型，如果无法转换则返回nil
    private func targetState(for event: ProvisioningEvent) -> ProvisioningStateType? {
        return transitions[currentState.type]?[event]
    }
    
    // MARK: - ProvisioningStateProtocol Implementation
    
    /// 处理事件并转换状态
    /// - Parameter event: 触发状态转换的事件
    /// - Returns: 转换后的状态
    func handleEvent(_ event: ProvisioningEvent) -> ProvisioningState {
        log.debug("处理事件: \(event), 当前状态: \(currentState.type)")
        
        // 检查是否可以转换
        guard canTransition(with: event) else {
            log.warning("无法从状态 \(currentState.type) 转换到事件 \(event)")
            return currentState
        }
        
        // 获取目标状态
        guard let targetType = targetState(for: event) else {
            log.warning("未找到事件 \(event) 对应的目标状态")
            return currentState
        }
        
        // 根据事件更新状态信息
        let newState = createNewState(from: currentState, with: event, targetType: targetType)
        currentState = newState
        
        log.info("状态转换: \(currentState.type.rawValue) -> \(targetType.rawValue)")
        return currentState
    }
    
    /// 根据事件创建新状态
    /// - Parameters:
    ///   - currentState: 当前状态
    ///   - event: 触发事件
    ///   - targetType: 目标状态类型
    /// - Returns: 新状态
    private func createNewState(from currentState: ProvisioningState, with event: ProvisioningEvent, targetType: ProvisioningStateType) -> ProvisioningState {
        var newState = ProvisioningState(type: targetType)
        
        switch event {
        case .deviceFound(let device):
            currentDevice = device
            newState = ProvisioningState(
                type: targetType,
                description: "发现设备: \(device.name)",
                device: device
            )
            
        case .networkSelected(let ssid):
            currentNetwork = NetworkInfo(ssid: ssid, security: .unknown, signalStrength: 0)
            newState = ProvisioningState(
                type: targetType,
                description: "选择网络: \(ssid)",
                network: currentNetwork
            )
            
        case .qrCodeScanned(let _):
            newState = ProvisioningState(
                type: targetType,
                description: "扫描到二维码数据"
            )
            
        case .provisioningProgress(let progress):
            newState = ProvisioningState(
                type: targetType,
                description: "配网进行中",
                progress: progress
            )
            
        case .provisioningFailed(let error):
            newState = ProvisioningState(
                type: targetType,
                description: "配网失败: \(error.localizedDescription)",
                error: error
            )
            
        case .provisioningSuccess:
            newState = ProvisioningState(
                type: targetType,
                description: "配网成功",
                device: currentDevice
            )
            
        default:
            // 使用默认状态描述
            newState = createStateWithDefaultDescription(for: targetType)
        }
        
        return newState
    }
    
    /// 为状态类型创建默认描述的状态
    /// - Parameter type: 状态类型
    /// - Returns: 带默认描述的状态
    private func createStateWithDefaultDescription(for type: ProvisioningStateType) -> ProvisioningState {
        let description: String
        
        switch type {
        case .idle:
            description = "初始状态"
        case .selectingMethod:
            description = "请选择配网方式"
        case .bluetoothScanning:
            description = "正在扫描蓝牙设备"
        case .bluetoothConnecting:
            description = "正在连接蓝牙设备"
        case .bluetoothProvisioning:
            description = "正在进行蓝牙配网"
        case .wifiScanning:
            description = "正在扫描WiFi网络"
        case .wifiConnecting:
            description = "正在连接WiFi网络"
        case .wifiProvisioning:
            description = "正在进行WiFi配网"
        case .qrCodeScanning:
            description = "请扫描设备二维码"
        case .qrCodeProcessing:
            description = "正在处理二维码数据"
        case .provisioning:
            description = "配网进行中"
        case .success:
            description = "配网成功"
        case .failed:
            description = "配网失败"
        case .completed:
            description = "配网完成"
        }
        
        return ProvisioningState(
            type: type,
            description: description,
            device: currentState.device,
            network: currentState.network
        )
    }
    
    /// 重置到初始状态
    func reset() {
        currentState = ProvisioningState(
            type: .idle,
            description: "初始状态"
        )
        currentDevice = nil
        currentNetwork = nil
        
        log.debug("状态机已重置到初始状态")
    }
}