//
//  AuthStateManager.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import Foundation
import Combine
import SwiftyBeaver

// MARK: - Authentication Events
enum AuthEvent {
    case loginSuccess(User)
    case loginFailed(Error)
    case logout
    case authRequired
}

// MARK: - Authentication State Manager
class AuthStateManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = AuthStateManager()
    
    // MARK: - Published Properties
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    
    // MARK: - Combine Subjects
    private let authEventSubject = PassthroughSubject<AuthEvent, Never>()
    
    // MARK: - Public Publishers
    var authEventPublisher: AnyPublisher<AuthEvent, Never> {
        authEventSubject.eraseToAnyPublisher()
    }
    
    private let log = SwiftyBeaver.self
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    private init() {
        checkAuthStatus()
    }
    
    // MARK: - Public Methods
    func checkAuthStatus() {
        // 这里应该检查本地存储的认证状态
        // 比如检查 UserDefaults 中的 token 或用户信息
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            self.isAuthenticated = true
            log.info("用户已登录: \(user.email)")
        } else {
            self.currentUser = nil
            self.isAuthenticated = false
            log.info("用户未登录")
        }
    }
    
    func login(user: User) {
        // 保存用户信息到本地存储
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
        
        self.currentUser = user
        self.isAuthenticated = true
        log.info("用户登录成功: \(user.email)")
        
        // 使用 Combine 发送登录成功事件
        authEventSubject.send(.loginSuccess(user))
    }
    
    func logout() {
        // 清除本地存储的用户信息
        UserDefaults.standard.removeObject(forKey: "currentUser")
        
        self.currentUser = nil
        self.isAuthenticated = false
        log.info("用户已登出")
        
        // 使用 Combine 发送登出事件
        authEventSubject.send(.logout)
    }
    
    func isUserLoggedIn() -> Bool {
        return isAuthenticated && currentUser != nil
    }
    
    func getCurrentUser() -> User? {
        return currentUser
    }
    
    // MARK: - Event Triggers
    func requireAuthentication() {
        authEventSubject.send(.authRequired)
    }
} 