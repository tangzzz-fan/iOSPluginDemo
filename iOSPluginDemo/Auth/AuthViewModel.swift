//
//  AuthViewModel.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import Foundation
import Combine

// MARK: - Auth View Model
class AuthViewModel: NSObject, ViewModelable, ViewModelErrorHandling {
    
    // MARK: - Properties
    var cancellables = Set<AnyCancellable>()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var title: String = "登录"
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoginEnabled: Bool = false
    @Published var isLoggedIn: Bool = false
    
    // MARK: - Services
    private let authService: AuthServiceProtocol
    private let authStateManager: AuthStateManager
    
    // MARK: - Initialization
    init(authService: AuthServiceProtocol, authStateManager: AuthStateManager) {
        self.authService = authService
        self.authStateManager = authStateManager
        super.init()
        setupBindings()
        
        // 设置默认测试账号，提升用户体验
        self.email = "test@example.com"
        self.password = "123456"
    }
    
    // MARK: - Setup
    func setupBindings() {
        // 监听输入变化，启用/禁用登录按钮
        Publishers.CombineLatest($email, $password)
            .map { email, password in
                !email.isEmpty && !password.isEmpty && email.contains("@")
            }
            .assign(to: \.isLoginEnabled, on: self)
            .store(in: &cancellables)
        
        // 监听错误消息
        $errorMessage
            .compactMap { $0 }
            .sink { [weak self] errorMessage in
                self?.log.warning("Auth error: \(errorMessage)")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    func login() {
        guard isLoginEnabled else { return }
        
        setLoading(true)
        clearError()
        
        let credentials = LoginCredentials(email: email, password: password)
        
        authService.login(credentials: credentials)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.setLoading(false)
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] user in
                    self?.isLoggedIn = true
                    // 保存用户登录状态 - AuthStateManager 会自动发送 Combine 事件
                    self?.authStateManager.login(user: user)
                    self?.log.info("User logged in successfully: \(user.email)")
                }
            )
            .store(in: &cancellables)
    }
    
    func logout() {
        authService.logout()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.isLoggedIn = false
                    self?.email = ""
                    self?.password = ""
                    // 清除用户登录状态
                    self?.authStateManager.logout()
                    self?.log.info("User logged out successfully")
                }
            )
            .store(in: &cancellables)
    }
    
    func checkAuthStatus() {
        // 检查当前认证状态
        if let currentUser = authStateManager.getCurrentUser() {
            self.isLoggedIn = true
            self.log.info("User is already logged in: \(currentUser.email)")
        } else {
            self.isLoggedIn = false
            self.log.info("User is not logged in")
        }
    }
} 