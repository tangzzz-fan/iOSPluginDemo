//
//  ProfileViewModel.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/8/25.
//

import Foundation
import Combine
import SwiftyBeaver

// MARK: - Profile View Model
class ProfileViewModel: NSObject, ViewModelable {
    
    // MARK: - Properties
    var cancellables = Set<AnyCancellable>()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var user: User?
    @Published var displayName: String = ""
    @Published var displayEmail: String = ""
    @Published var avatarURL: String?
    
    // MARK: - Services
    private let authStateManager: AuthStateManager
    
    // MARK: - Initialization
    init(authStateManager: AuthStateManager) {
        self.authStateManager = authStateManager
        super.init()
        setupBindings()
        loadUserProfile()
    }
    
    // MARK: - Setup
    func setupBindings() {
        // 监听认证状态变化
        authStateManager.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.user = user
                if let user = user {
                    self?.displayName = user.name
                    self?.displayEmail = user.email
                    self?.avatarURL = user.avatarURL
                } else {
                    self?.displayName = ""
                    self?.displayEmail = ""
                    self?.avatarURL = nil
                }
            }
            .store(in: &cancellables)
        
        // 监听加载状态
        $isLoading
            .sink { [weak self] isLoading in
                self?.log.info("Profile loading state: \(isLoading)")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    func loadUserProfile() {
        if let currentUser = authStateManager.getCurrentUser() {
            self.user = currentUser
            self.displayName = currentUser.name
            self.displayEmail = currentUser.email
            self.avatarURL = currentUser.avatarURL
            log.info("Profile loaded for user: \(currentUser.email)")
        } else {
            log.warning("No user logged in to load profile")
        }
    }
    
    func refreshProfile() {
        setLoading(true)
        clearError()
        
        // 模拟刷新操作
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) { [weak self] in
            DispatchQueue.main.async {
                self?.setLoading(false)
                self?.loadUserProfile()
                self?.log.info("Profile refreshed")
            }
        }
    }
    
    func logout() {
        authStateManager.logout()
        log.info("User logged out from profile")
    }
    
    // MARK: - Computed Properties
    var isUserLoggedIn: Bool {
        return authStateManager.isUserLoggedIn()
    }
    
    var userInitials: String {
        guard let user = user else { return "?" }
        let components = user.name.components(separatedBy: " ")
        if components.count >= 2 {
            let firstInitial = String(components[0].prefix(1))
            let lastInitial = String(components[1].prefix(1))
            return "\(firstInitial)\(lastInitial)".uppercased()
        } else {
            return String(user.name.prefix(1)).uppercased()
        }
    }
}