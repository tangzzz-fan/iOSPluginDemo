//
//  DeviceStateManager.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import Foundation
import Combine

/// 设备状态管理器协议
protocol DeviceStateManagerProtocol: AnyObject {
    /// 获取设备状态
    /// - Parameter deviceId: 设备ID
    /// - Returns: 设备状态
    func getDeviceStatus(for deviceId: String) -> DeviceStatus?
    
    /// 更新设备状态
    /// - Parameters:
    ///   - deviceId: 设备ID
    ///   - status: 新状态
    func updateDeviceStatus(for deviceId: String, status: DeviceStatus)
    
    /// 订阅设备状态变化
    /// - Parameter deviceId: 设备ID
    /// - Returns: 设备状态变化的Publisher
    func subscribeToDeviceStatusChanges(for deviceId: String) -> AnyPublisher<DeviceStatus, Never>
    
    /// 获取所有设备状态
    /// - Returns: 所有设备状态的映射
    func getAllDeviceStatuses() -> [String: DeviceStatus]
    
    /// 清除设备状态
    /// - Parameter deviceId: 设备ID
    func clearDeviceStatus(for deviceId: String)
}

/// 设备状态管理器实现
class DeviceStateManager: DeviceStateManagerProtocol, Loggable {
    // MARK: - Properties
    
    // 设备状态映射
    private var deviceStatuses: [String: DeviceStatus] = [:]
    
    // 设备状态变化Subject
    private var deviceStatusSubjects: [String: CurrentValueSubject<DeviceStatus, Never>] = [:]
    
    // 所有设备状态变化的Subject
    private let allDeviceStatusSubject = CurrentValueSubject<[String: DeviceStatus], Never>([:])
    
    // 线程安全队列
    private let queue = DispatchQueue(label: "DeviceStateManagerQueue", attributes: .concurrent)
    
    // MARK: - Initialization
    
    init() {
        log.debug("设备状态管理器初始化完成")
    }
    
    // MARK: - DeviceStateManagerProtocol Implementation
    
    /// 获取设备状态
    /// - Parameter deviceId: 设备ID
    /// - Returns: 设备状态
    func getDeviceStatus(for deviceId: String) -> DeviceStatus? {
        return queue.sync {
            deviceStatuses[deviceId]
        }
    }
    
    /// 更新设备状态
    /// - Parameters:
    ///   - deviceId: 设备ID
    ///   - status: 新状态
    func updateDeviceStatus(for deviceId: String, status: DeviceStatus) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            // 更新设备状态
            self.deviceStatuses[deviceId] = status
            
            // 发送状态变化通知
            DispatchQueue.main.async {
                // 更新特定设备的Subject
                if let subject = self.deviceStatusSubjects[deviceId] {
                    subject.send(status)
                } else {
                    let subject = CurrentValueSubject<DeviceStatus, Never>(status)
                    self.deviceStatusSubjects[deviceId] = subject
                }
                
                // 更新所有设备状态的Subject
                self.allDeviceStatusSubject.send(self.deviceStatuses)
                
                self.log.debug("设备状态更新: \(deviceId) -> \(status)")
            }
        }
    }
    
    /// 订阅设备状态变化
    /// - Parameter deviceId: 设备ID
    /// - Returns: 设备状态变化的Publisher
    func subscribeToDeviceStatusChanges(for deviceId: String) -> AnyPublisher<DeviceStatus, Never> {
        return queue.sync {
            if let subject = deviceStatusSubjects[deviceId] {
                return subject.eraseToAnyPublisher()
            } else {
                // 如果还没有该设备的Subject，创建一个新的
                let currentStatus = deviceStatuses[deviceId] ?? .unknown
                let subject = CurrentValueSubject<DeviceStatus, Never>(currentStatus)
                deviceStatusSubjects[deviceId] = subject
                return subject.eraseToAnyPublisher()
            }
        }
    }
    
    /// 获取所有设备状态
    /// - Returns: 所有设备状态的映射
    func getAllDeviceStatuses() -> [String: DeviceStatus] {
        return queue.sync {
            deviceStatuses
        }
    }
    
    /// 清除设备状态
    /// - Parameter deviceId: 设备ID
    func clearDeviceStatus(for deviceId: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            // 移除设备状态
            self.deviceStatuses.removeValue(forKey: deviceId)
            
            // 移除设备状态Subject
            self.deviceStatusSubjects.removeValue(forKey: deviceId)
            
            DispatchQueue.main.async {
                // 更新所有设备状态的Subject
                self.allDeviceStatusSubject.send(self.deviceStatuses)
                
                self.log.debug("设备状态清除: \(deviceId)")
            }
        }
    }
}