//
//  ProvisioningService.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import Foundation
import Combine

/// 配网服务结果
enum ProvisioningServiceResult {
    case success(ProvisioningDevice)
    case failure(Error)
}

/// 配网服务协议
protocol ProvisioningServiceProtocol: AnyObject, Loggable {
    /// 开始配网
    /// - Parameters:
    ///   - device: 要配网的设备
    ///   - config: 配网配置
    /// - Returns: 用于接收配网结果的Publisher
    func startProvisioning(for device: ProvisioningDevice, with config: ProvisioningConfiguration) -> AnyPublisher<ProvisioningServiceResult, Error>
    
    /// 取消配网
    func cancelProvisioning()
    
    /// 检查服务是否可用
    /// - Returns: 服务是否可用
    func isServiceAvailable() -> Bool
}

/// 蓝牙配网服务协议
protocol BluetoothProvisioningServiceProtocol: ProvisioningServiceProtocol {
    /// 扫描蓝牙设备
    /// - Returns: 用于接收扫描结果的Publisher
    func scanForDevices() -> AnyPublisher<[ProvisioningDevice], Error>
    
    /// 连接蓝牙设备
    /// - Parameter device: 要连接的设备
    /// - Returns: 用于接收连接结果的Publisher
    func connect(to device: ProvisioningDevice) -> AnyPublisher<Bool, Error>
}

/// WiFi配网服务协议
protocol WiFiProvisioningServiceProtocol: ProvisioningServiceProtocol {
    /// 扫描WiFi网络
    /// - Returns: 用于接收扫描结果的Publisher
    func scanForNetworks() -> AnyPublisher<[NetworkInfo], Error>
    
    /// 连接WiFi网络
    /// - Parameters:
    ///   - network: 要连接的网络
    ///   - password: 网络密码
    /// - Returns: 用于接收连接结果的Publisher
    func connect(to network: NetworkInfo, with password: String) -> AnyPublisher<Bool, Error>
}

/// 二维码配网服务协议
protocol QRCodeProvisioningServiceProtocol: ProvisioningServiceProtocol {
    /// 处理二维码数据
    /// - Parameter qrCodeData: 二维码数据
    /// - Returns: 用于接收处理结果的Publisher
    func processQRCodeData(_ qrCodeData: String) -> AnyPublisher<ProvisioningConfiguration, Error>
}