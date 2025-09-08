//
//  ControlCommand.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import Foundation

/// 控制命令模型
struct ControlCommand: Codable, Equatable {
    /// 命令ID
    let id: String
    
    /// 设备ID
    let deviceId: String
    
    /// 命令类型
    let type: CommandType
    
    /// 命令参数
    let parameters: [String: AnyCodable]
    
    /// 时间戳
    let timestamp: Date
    
    /// 是否需要确认
    let requiresAcknowledgment: Bool
    
    init(id: String = UUID().uuidString, deviceId: String, type: CommandType, parameters: [String: AnyCodable] = [:], timestamp: Date = Date(), requiresAcknowledgment: Bool = true) {
        self.id = id
        self.deviceId = deviceId
        self.type = type
        self.parameters = parameters
        self.timestamp = timestamp
        self.requiresAcknowledgment = requiresAcknowledgment
    }
}

/// 命令类型枚举
enum CommandType: String, Codable, CaseIterable {
    // 通用命令
    case powerOn = "PowerOn"                     // 开机
    case powerOff = "PowerOff"                   // 关机
    case reset = "Reset"                         // 重置
    
    // 移动设备命令
    case moveTo = "MoveTo"                       // 移动到指定位置
    case startCleaning = "StartCleaning"         // 开始清扫
    case pauseCleaning = "PauseCleaning"         // 暂停清扫
    case returnToDock = "ReturnToDock"           // 返回充电座
    
    // 状态查询命令
    case getStatus = "GetStatus"                 // 获取状态
    case getBatteryLevel = "GetBatteryLevel"     // 获取电量
    case getSchedule = "GetSchedule"             // 获取计划
    
    // 配置命令
    case setSchedule = "SetSchedule"             // 设置计划
    case setCleaningMode = "SetCleaningMode"     // 设置清扫模式
    case setVolume = "SetVolume"                 // 设置音量
    
    // OTA升级命令
    case startOTA = "StartOTA"                   // 开始OTA升级
    case cancelOTA = "CancelOTA"                 // 取消OTA升级
    
    // Matter设备特定命令
    case matterIdentify = "MatterIdentify"       // Matter设备识别
    case matterReadAttribute = "MatterReadAttribute" // 读取Matter属性
    case matterWriteAttribute = "MatterWriteAttribute" // 写入Matter属性
    case matterInvokeCommand = "MatterInvokeCommand" // 调用Matter命令
}

/// 可编码的任意类型包装器
struct AnyCodable: Codable, Equatable {
    let value: Any
    
    init<T>(_ value: T?) {
        self.value = value ?? ()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(Bool.self) {
            self.value = value
        } else if let value = try? container.decode(Int.self) {
            self.value = value
        } else if let value = try? container.decode(Double.self) {
            self.value = value
        } else if let value = try? container.decode(String.self) {
            self.value = value
        } else if let value = try? container.decode([AnyCodable].self) {
            self.value = value.map { $0.value }
        } else if let value = try? container.decode([String: AnyCodable].self) {
            self.value = value.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "无法解码 AnyCodable 值")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let value as Bool:
            try container.encode(value)
        case let value as Int:
            try container.encode(value)
        case let value as Int8:
            try container.encode(value)
        case let value as Int16:
            try container.encode(value)
        case let value as Int32:
            try container.encode(value)
        case let value as Int64:
            try container.encode(value)
        case let value as UInt:
            try container.encode(value)
        case let value as UInt8:
            try container.encode(value)
        case let value as UInt16:
            try container.encode(value)
        case let value as UInt32:
            try container.encode(value)
        case let value as UInt64:
            try container.encode(value)
        case let value as Float:
            try container.encode(value)
        case let value as Double:
            try container.encode(value)
        case let value as String:
            try container.encode(value)
        case let value as [Any]:
            try container.encode(value.map { AnyCodable($0) })
        case let value as [String: Any]:
            try container.encode(value.mapValues { AnyCodable($0) })
        case is Void:
            try container.encodeNil()
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "无法编码 AnyCodable 值")
            throw EncodingError.invalidValue(value, context)
        }
    }
    
    static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        switch (lhs.value, rhs.value) {
        case (let l as Bool, let r as Bool):
            return l == r
        case (let l as Int, let r as Int):
            return l == r
        case (let l as Int8, let r as Int8):
            return l == r
        case (let l as Int16, let r as Int16):
            return l == r
        case (let l as Int32, let r as Int32):
            return l == r
        case (let l as Int64, let r as Int64):
            return l == r
        case (let l as UInt, let r as UInt):
            return l == r
        case (let l as UInt8, let r as UInt8):
            return l == r
        case (let l as UInt16, let r as UInt16):
            return l == r
        case (let l as UInt32, let r as UInt32):
            return l == r
        case (let l as UInt64, let r as UInt64):
            return l == r
        case (let l as Float, let r as Float):
            return l == r
        case (let l as Double, let r as Double):
            return l == r
        case (let l as String, let r as String):
            return l == r
        case (let l as [Any], let r as [Any]):
            return l.map { AnyCodable($0) } == r.map { AnyCodable($0) }
        case (let l as [String: Any], let r as [String: Any]):
            return l.mapValues { AnyCodable($0) } == r.mapValues { AnyCodable($0) }
        case (is Void, is Void):
            return true
        default:
            return false
        }
    }
}