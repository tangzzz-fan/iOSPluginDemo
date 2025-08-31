//
//  DemoModels.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/1/27.
//

import Foundation
import UIKit

// MARK: - Demo Item Model
struct DemoItem {
    let id: String
    let title: String
    let description: String
    let icon: UIImage?
    let category: DemoCategory
    let action: DemoAction
    
    init(id: String, title: String, description: String, icon: UIImage?, category: DemoCategory, action: DemoAction) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.category = category
        self.action = action
    }
}

// MARK: - Demo Category
enum DemoCategory: String, CaseIterable {
    case ui = "UI演示"
    case animation = "动画效果"
    case networking = "网络功能"
    case storage = "数据存储"
    case media = "媒体处理"
    case sharing = "分享功能"
    case utility = "实用工具"
    
    var color: UIColor {
        switch self {
        case .ui:
            return .systemBlue
        case .animation:
            return .systemGreen
        case .networking:
            return .systemOrange
        case .storage:
            return .systemPurple
        case .media:
            return .systemRed
        case .sharing:
            return .systemTeal
        case .utility:
            return .systemIndigo
        }
    }
}

// MARK: - Demo Action
enum DemoAction {
    case longScreenshot
    case scrollAnimation
    case networkRequest
    case dataStorage
    case imageProcessing
    case socialSharing
    case qrCodeGeneration
    case biometricAuth
    case pushNotification
    case coreDataDemo
    case custom(action: () -> Void)
    
    var title: String {
        switch self {
        case .longScreenshot:
            return "长截图分享"
        case .scrollAnimation:
            return "滚动动画"
        case .networkRequest:
            return "网络请求"
        case .dataStorage:
            return "数据存储"
        case .imageProcessing:
            return "图像处理"
        case .socialSharing:
            return "社交分享"
        case .qrCodeGeneration:
            return "二维码生成"
        case .biometricAuth:
            return "生物识别"
        case .pushNotification:
            return "推送通知"
        case .coreDataDemo:
            return "CoreData演示"
        case .custom:
            return "自定义功能"
        }
    }
}

// MARK: - Demo Data Provider
struct DemoDataProvider {
    static func getAllDemos() -> [DemoItem] {
        return [
            // 分享功能
            DemoItem(
                id: "long_screenshot",
                title: "长截图分享",
                description: "生成当前页面的完整长截图并支持分享到各个平台",
                icon: UIImage(systemName: "camera.viewfinder"),
                category: .sharing,
                action: .longScreenshot
            ),
            
            // UI演示
            DemoItem(
                id: "scroll_animation",
                title: "滚动动画演示",
                description: "展示各种滚动视图的动画效果和交互方式",
                icon: UIImage(systemName: "list.bullet.rectangle"),
                category: .ui,
                action: .scrollAnimation
            ),
            
            // 网络功能
            DemoItem(
                id: "network_request",
                title: "网络请求演示",
                description: "使用Combine + Moya实现的网络请求和响应处理",
                icon: UIImage(systemName: "network"),
                category: .networking,
                action: .networkRequest
            ),
            
            // 数据存储
            DemoItem(
                id: "data_storage",
                title: "数据存储方案",
                description: "演示UserDefaults、Keychain、CoreData等存储方案",
                icon: UIImage(systemName: "internaldrive"),
                category: .storage,
                action: .dataStorage
            ),
            
            // 媒体处理
            DemoItem(
                id: "image_processing",
                title: "图像处理功能",
                description: "图像滤镜、裁剪、压缩等处理功能演示",
                icon: UIImage(systemName: "photo.artframe"),
                category: .media,
                action: .imageProcessing
            ),
            
            // 实用工具
            DemoItem(
                id: "qr_code",
                title: "二维码生成器",
                description: "生成各种类型的二维码，支持自定义样式",
                icon: UIImage(systemName: "qrcode"),
                category: .utility,
                action: .qrCodeGeneration
            ),
            
            DemoItem(
                id: "biometric_auth",
                title: "生物识别认证",
                description: "Touch ID / Face ID 生物识别认证演示",
                icon: UIImage(systemName: "faceid"),
                category: .utility,
                action: .biometricAuth
            ),
            
            DemoItem(
                id: "push_notification",
                title: "推送通知",
                description: "本地和远程推送通知的实现和处理",
                icon: UIImage(systemName: "bell.badge"),
                category: .utility,
                action: .pushNotification
            )
        ]
    }
    
    static func getDemosByCategory() -> [DemoCategory: [DemoItem]] {
        let allDemos = getAllDemos()
        let grouped = Dictionary(grouping: allDemos) { $0.category }
        return grouped
    }
}
