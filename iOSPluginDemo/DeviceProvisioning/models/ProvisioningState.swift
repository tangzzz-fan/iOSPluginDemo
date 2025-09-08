//
//  ProvisioningState.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import Foundation

/// 配网状态模型
struct ProvisioningState: Equatable {
    // MARK: - Equatable
    
    static func == (lhs: ProvisioningState, rhs: ProvisioningState) -> Bool {
        return lhs.type == rhs.type &&
               lhs.description == rhs.description &&
               lhs.progress == rhs.progress &&
               lhs.device?.id == rhs.device?.id &&
               lhs.network?.ssid == rhs.network?.ssid
    }
    /// 当前状态类型
    let type: ProvisioningStateType
    
    /// 状态描述
    let description: String
    
    /// 配网进度 (0.0 - 1.0)
    let progress: Float
    
    /// 错误信息 (如果有的话)
    let error: Error?
    
    /// 关联的设备信息
    let device: ProvisioningDevice?
    
    /// 关联的网络信息
    let network: NetworkInfo?
    
    init(
        type: ProvisioningStateType,
        description: String = "",
        progress: Float = 0.0,
        error: Error? = nil,
        device: ProvisioningDevice? = nil,
        network: NetworkInfo? = nil
    ) {
        self.type = type
        self.description = description
        self.progress = progress
        self.error = error
        self.device = device
        self.network = network
    }
}

