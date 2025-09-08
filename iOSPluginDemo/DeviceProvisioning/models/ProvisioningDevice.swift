//
//  ProvisioningDevice.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import Foundation

/// 配网设备模型
struct ProvisioningDevice: Codable, Equatable, Hashable {
    /// 设备ID
    let id: String
    
    /// 设备名称
    let name: String
    
    /// 设备类型
    let type: DeviceType
    
    /// 设备信号强度 (蓝牙设备)
    let rssi: Int?
    
    /// 设备IP地址 (WiFi设备)
    let ipAddress: String?
    
    /// 是否已配网
    let isProvisioned: Bool
    
    /// 设备支持的配网方式
    let supportedMethods: [ProvisioningMethodType]
    
    init(id: String, name: String, type: DeviceType, rssi: Int? = nil, ipAddress: String? = nil, isProvisioned: Bool = false, supportedMethods: [ProvisioningMethodType] = []) {
        self.id = id
        self.name = name
        self.type = type
        self.rssi = rssi
        self.ipAddress = ipAddress
        self.isProvisioned = isProvisioned
        self.supportedMethods = supportedMethods
    }
}

/// 设备类型枚举
enum DeviceType: String, Codable, CaseIterable, Hashable {
    case vacuumCleaner = "VacuumCleaner"  // 扫地机器人
    case airPurifier = "AirPurifier"      // 空气净化器
    case smartLight = "SmartLight"        // 智能灯泡
    case smartSocket = "SmartSocket"      // 智能插座
    case camera = "Camera"                // 摄像头
    case other = "Other"                  // 其他设备
}

/// 配网方式枚举
enum ProvisioningMethodType: String, Codable, CaseIterable, Hashable {
    case bluetooth = "Bluetooth"    // 蓝牙配网
    case wifi = "WiFi"              // WiFi配网
    case qrCode = "QRCode"          // 二维码配网
}