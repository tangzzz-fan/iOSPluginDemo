//
//  Device.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import Foundation

/// 设备控制模块的设备类型枚举
enum DeviceControlDeviceType: String, Codable, CaseIterable {
    case vacuumCleaner = "VacuumCleaner"     // 扫地机器人
    case lawnMower = "LawnMower"             // 草地机器人
    case poolCleaner = "PoolCleaner"         // 泳池清洁机器人
    case humanoidRobot = "HumanoidRobot"     // 具身机器人
    case airPurifier = "AirPurifier"         // 空气净化器
    case smartLight = "SmartLight"           // 智能灯泡
    case smartSocket = "SmartSocket"         // 智能插座
    case camera = "Camera"                   // 摄像头
    case other = "Other"                     // 其他设备
}

/// 设备模型
struct Device: Codable, Equatable {
    /// 设备ID
    let id: String
    
    /// 设备名称
    let name: String
    
    /// 设备类型
    let type: DeviceControlDeviceType
    
    /// 设备信号强度 (蓝牙设备)
    let rssi: Int?
    
    /// 设备IP地址 (WiFi设备)
    let ipAddress: String?
    
    /// 是否已连接
    let isConnected: Bool
    
    /// 连接方式
    let connectionType: ConnectionType
    
    /// 设备状态
    let status: DeviceStatus
    
    init(id: String, name: String, type: DeviceControlDeviceType, rssi: Int? = nil, ipAddress: String? = nil, isConnected: Bool = false, connectionType: ConnectionType = .bluetooth, status: DeviceStatus = .unknown) {
        self.id = id
        self.name = name
        self.type = type
        self.rssi = rssi
        self.ipAddress = ipAddress
        self.isConnected = isConnected
        self.connectionType = connectionType
        self.status = status
    }
}

/// 连接方式枚举
enum ConnectionType: String, Codable, CaseIterable {
    case bluetooth = "Bluetooth"    // 蓝牙连接
    case wifi = "WiFi"              // WiFi连接
    case mqtt = "MQTT"              // MQTT连接
    case matter = "Matter"          // Matter连接
    case cloud = "Cloud"            // 云端连接
}

/// 设备状态枚举
enum DeviceStatus: String, Codable, CaseIterable {
    case unknown = "Unknown"           // 未知状态
    case idle = "Idle"                 // 空闲状态
    case working = "Working"           // 工作状态
    case charging = "Charging"         // 充电状态
    case error = "Error"               // 错误状态
    case offline = "Offline"           // 离线状态
    case updating = "Updating"         // 更新状态
}