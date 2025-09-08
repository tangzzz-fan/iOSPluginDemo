//
//  ProvisioningStateProtocol.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import Foundation

/// 配网状态类型枚举
enum ProvisioningStateType: String, CaseIterable, Codable, Hashable {
    case idle = "Idle"                                      // 初始状态
    case selectingMethod = "SelectingMethod"                // 选择配网方式
    case bluetoothScanning = "BluetoothScanning"            // 蓝牙扫描设备
    case bluetoothConnecting = "BluetoothConnecting"        // 蓝牙连接设备
    case bluetoothProvisioning = "BluetoothProvisioning"    // 蓝牙配网中
    case wifiScanning = "WiFiScanning"                      // WiFi扫描网络
    case wifiConnecting = "WiFiConnecting"                  // WiFi连接网络
    case wifiProvisioning = "WiFiProvisioning"              // WiFi配网中
    case qrCodeScanning = "QRCodeScanning"                  // 扫描二维码
    case qrCodeProcessing = "QRCodeProcessing"              // 处理二维码数据
    case provisioning = "Provisioning"                      // 配网进行中
    case success = "Success"                                // 配网成功
    case failed = "Failed"                                  // 配网失败
    case completed = "Completed"                            // 配网完成
}

/// 配网事件枚举
enum ProvisioningEvent: Hashable {
    case startProvisioning                              // 开始配网
    case selectBluetoothMethod                          // 选择蓝牙配网
    case selectWiFiMethod                               // 选择WiFi配网
    case selectQRCodeMethod                             // 选择扫码配网
    case deviceFound(ProvisioningDevice)                // 发现设备
    case deviceConnected                                // 设备连接成功
    case networkSelected(String)                        // 选择网络
    case qrCodeScanned(String)                          // 扫描到二维码
    case provisioningProgress(Float)                    // 配网进度更新
    case provisioningSuccess                            // 配网成功
    case provisioningFailed(Error)                      // 配网失败
    case retry                                          // 重试
    case cancel                                         // 取消
    case finish                                         // 完成
    
    // Hashable conformance for associated values
    func hash(into hasher: inout Hasher) {
        switch self {
        case .startProvisioning:
            hasher.combine(0)
        case .selectBluetoothMethod:
            hasher.combine(1)
        case .selectWiFiMethod:
            hasher.combine(2)
        case .selectQRCodeMethod:
            hasher.combine(3)
        case .deviceFound(let device):
            hasher.combine(4)
            hasher.combine(device)
        case .deviceConnected:
            hasher.combine(5)
        case .networkSelected(let network):
            hasher.combine(6)
            hasher.combine(network)
        case .qrCodeScanned(let code):
            hasher.combine(7)
            hasher.combine(code)
        case .provisioningProgress(let progress):
            hasher.combine(8)
            hasher.combine(progress)
        case .provisioningSuccess:
            hasher.combine(9)
        case .provisioningFailed(let error):
            hasher.combine(10)
            hasher.combine(error.localizedDescription)
        case .retry:
            hasher.combine(11)
        case .cancel:
            hasher.combine(12)
        case .finish:
            hasher.combine(13)
        }
    }
    
    // Equatable conformance for associated values
    static func == (lhs: ProvisioningEvent, rhs: ProvisioningEvent) -> Bool {
        switch (lhs, rhs) {
        case (.startProvisioning, .startProvisioning),
             (.selectBluetoothMethod, .selectBluetoothMethod),
             (.selectWiFiMethod, .selectWiFiMethod),
             (.selectQRCodeMethod, .selectQRCodeMethod),
             (.deviceConnected, .deviceConnected),
             (.provisioningSuccess, .provisioningSuccess),
             (.retry, .retry),
             (.cancel, .cancel),
             (.finish, .finish):
            return true
        case (.deviceFound(let lhsDevice), .deviceFound(let rhsDevice)):
            return lhsDevice == rhsDevice
        case (.networkSelected(let lhsNetwork), .networkSelected(let rhsNetwork)):
            return lhsNetwork == rhsNetwork
        case (.qrCodeScanned(let lhsCode), .qrCodeScanned(let rhsCode)):
            return lhsCode == rhsCode
        case (.provisioningProgress(let lhsProgress), .provisioningProgress(let rhsProgress)):
            return lhsProgress == rhsProgress
        case (.provisioningFailed(let lhsError), .provisioningFailed(let rhsError)):
            // 对于错误比较，我们简单地比较错误描述
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

/// 配网状态协议
protocol ProvisioningStateMachineProtocol: AnyObject, Loggable {
    /// 当前状态
    var currentState: ProvisioningState { get }
    
    /// 状态变化回调闭包
    var onStateChanged: ((ProvisioningState) -> Void)? { get set }
    
    /// 处理事件并转换状态
    /// - Parameter event: 触发状态转换的事件
    /// - Returns: 转换后的状态
    func handleEvent(_ event: ProvisioningEvent) -> ProvisioningState
    
    /// 重置到初始状态
    func reset()
}

/// 配网结果枚举
enum ProvisioningResult: Equatable {
    case success(ProvisioningDevice)
    case failure(Error)
    case cancelled
    
    static func == (lhs: ProvisioningResult, rhs: ProvisioningResult) -> Bool {
        switch (lhs, rhs) {
        case (.success(let lhsDevice), .success(let rhsDevice)):
            return lhsDevice.id == rhsDevice.id
        case (.failure(let lhsError), .failure(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.cancelled, .cancelled):
            return true
        default:
            return false
        }
    }
}