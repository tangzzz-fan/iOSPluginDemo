//
//  SettingsViewModel.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import Foundation
import Combine

// MARK: - Settings View Model
class SettingsViewModel: NSObject, ViewModelable, ViewModelErrorHandling {
    
    // MARK: - Properties
    var cancellables = Set<AnyCancellable>()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var title: String = "设置"
    
    // MARK: - Services
    private let authStateManager = AuthStateManager.shared
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    // MARK: - Actions
    func logout() {
        setLoading(true)
        clearError()
        
        // 直接使用 AuthStateManager 进行登出 - 它会自动发送 Combine 事件
        authStateManager.logout()
        
        setLoading(false)
        log.info("User logged out successfully")
    }
}