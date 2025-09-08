//
//  ProvisioningConfiguration.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import Foundation

/// 配网配置模型
struct ProvisioningConfiguration: Codable, Equatable {
    /// WiFi网络名称
    let ssid: String?
    
    /// WiFi密码
    let password: String?
    
    /// 设备名称
    let deviceName: String?
    
    /// 配网超时时间 (秒)
    let timeout: TimeInterval
    
    /// 重试次数
    let maxRetries: Int
    
    /// 是否启用加密传输
    let encrypted: Bool
    
    init(
        ssid: String? = nil,
        password: String? = nil,
        deviceName: String? = nil,
        timeout: TimeInterval = 60.0,
        maxRetries: Int = 3,
        encrypted: Bool = true
    ) {
        self.ssid = ssid
        self.password = password
        self.deviceName = deviceName
        self.timeout = timeout
        self.maxRetries = maxRetries
        self.encrypted = encrypted
    }
    
    /// 默认配置
    static let `default` = ProvisioningConfiguration()
    
    /// 蓝牙配网配置
    static func bluetoothConfiguration(deviceName: String?, timeout: TimeInterval = 60.0) -> ProvisioningConfiguration {
        return ProvisioningConfiguration(
            deviceName: deviceName,
            timeout: timeout,
            encrypted: true
        )
    }
    
    /// WiFi配网配置
    static func wifiConfiguration(ssid: String, password: String, deviceName: String?, timeout: TimeInterval = 120.0) -> ProvisioningConfiguration {
        return ProvisioningConfiguration(
            ssid: ssid,
            password: password,
            deviceName: deviceName,
            timeout: timeout,
            encrypted: true
        )
    }
    
    /// 二维码配网配置
    static func qrCodeConfiguration(deviceName: String?, timeout: TimeInterval = 60.0) -> ProvisioningConfiguration {
        return ProvisioningConfiguration(
            deviceName: deviceName,
            timeout: timeout,
            encrypted: true
        )
    }
}