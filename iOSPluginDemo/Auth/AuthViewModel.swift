//
//  AuthViewModel.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import Foundation
import Combine
import SwiftyBeaver

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
    private let authStateManager = AuthStateManager.shared
    
    // MARK: - Initialization
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        super.init()
        setupBindings()
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
        
        authService.login(email: email, password: password)
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
                    // 保存用户登录状态
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
        authService.checkAuthStatus()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.isLoggedIn = false
                        self?.log.warning("Auth status check failed: \(error)")
                    }
                },
                receiveValue: { [weak self] user in
                    self?.isLoggedIn = true
                    // 更新认证状态管理器
                    self?.authStateManager.login(user: user)
                    self?.log.info("User is already logged in: \(user.email)")
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - User Model
struct User: Codable {
    let id: String
    let email: String
    let name: String
    let avatarURL: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case avatarURL = "avatar_url"
        case createdAt = "created_at"
    }
}

// MARK: - Auth Service Protocol
protocol AuthServiceProtocol {
    func login(email: String, password: String) -> AnyPublisher<User, Error>
    func logout() -> AnyPublisher<Void, Error>
    func checkAuthStatus() -> AnyPublisher<User, Error>
    func forgotPassword(email: String) -> AnyPublisher<Void, Error>
    func register(email: String, password: String, name: String) -> AnyPublisher<User, Error>
}

// MARK: - Auth Service Implementation
class AuthService: AuthServiceProtocol {
    private let log = SwiftyBeaver.self
    
    func login(email: String, password: String) -> AnyPublisher<User, Error> {
        // 模拟网络请求
        return Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
                // 模拟验证逻辑
                if email == "test@example.com" && password == "password" {
                    let user = User(
                        id: UUID().uuidString,
                        email: email,
                        name: "测试用户",
                        avatarURL: nil,
                        createdAt: Date()
                    )
                    promise(.success(user))
                } else {
                    promise(.failure(AuthError.invalidCredentials))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, Error> {
        return Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func checkAuthStatus() -> AnyPublisher<User, Error> {
        return Future { promise in
            // 检查本地存储的认证状态
            // 这里简化处理，实际应该检查 token 等
            promise(.failure(AuthError.notAuthenticated))
        }
        .eraseToAnyPublisher()
    }
    
    func forgotPassword(email: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func register(email: String, password: String, name: String) -> AnyPublisher<User, Error> {
        return Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
                let user = User(
                    id: UUID().uuidString,
                    email: email,
                    name: name,
                    avatarURL: nil,
                    createdAt: Date()
                )
                promise(.success(user))
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Auth Error
enum AuthError: LocalizedError {
    case invalidCredentials
    case notAuthenticated
    case networkError
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "邮箱或密码错误"
        case .notAuthenticated:
            return "用户未登录"
        case .networkError:
            return "网络连接错误"
        case .serverError:
            return "服务器错误"
        }
    }
} 