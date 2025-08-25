//
//  AppDelegate.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import UIKit
import SwiftyBeaver

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 初始化日志系统
        AppLogger.configure()
        AppLogger.info("App launched")
        
        // 初始化依赖注入容器
        _ = DIContainerManagerImpl.shared
        AppLogger.info("依赖注入容器初始化成功")
        
        // 验证架构
        // ArchitectureValidator.validate()
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

