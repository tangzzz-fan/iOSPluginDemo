//
//  AuthService.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/8/25.
//

import Foundation
import Combine
import SwiftyBeaver

// MARK: - Auth Service Protocol
protocol AuthServiceProtocol {
    func login(credentials: LoginCredentials) -> AnyPublisher<User, AuthError>
    func register(data: RegistrationData) -> AnyPublisher<User, AuthError>
    func logout() -> AnyPublisher<Void, AuthError>
    func resetPassword(email: String) -> AnyPublisher<Void, AuthError>
    func getCurrentUser() -> User?
}

// MARK: - Auth Service Implementation
class AuthService: AuthServiceProtocol {
    
    // MARK: - Properties
    private let authStateManager: AuthStateManager
    
    // 模拟数据存储
    private var mockUsers: [User] = [
        User(email: "test@example.com", name: "测试用户"),
        User(email: "admin@example.com", name: "管理员")
    ]
    
    // MARK: - Initialization
    init(authStateManager: AuthStateManager) {
        self.authStateManager = authStateManager
    }
    
    // MARK: - Auth Service Methods
    func login(credentials: LoginCredentials) -> AnyPublisher<User, AuthError> {
        return Future<User, AuthError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknownError("Service is nil")))
                return
            }
            
            SwiftyBeaver.info("开始登录: \(credentials.email)")
            
            // 验证凭据格式
            guard credentials.isValid else {
                SwiftyBeaver.error("登录凭据无效")
                promise(.failure(.invalidCredentials))
                return
            }
            
            // 模拟网络延迟
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                // 模拟登录逻辑
                if self.validateCredentials(credentials) {
                    if let user = self.mockUsers.first(where: { $0.email == credentials.email }) {
                        SwiftyBeaver.info("登录成功: \(user.email)")
                        
                        // 更新认证状态
                        DispatchQueue.main.async {
                            self.authStateManager.login(user: user)
                        }
                        
                        promise(.success(user))
                    } else {
                        SwiftyBeaver.error("用户不存在: \(credentials.email)")
                        promise(.failure(.userNotFound))
                    }
                } else {
                    SwiftyBeaver.error("登录凭据错误")
                    promise(.failure(.invalidCredentials))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func register(data: RegistrationData) -> AnyPublisher<User, AuthError> {
        return Future<User, AuthError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknownError("Service is nil")))
                return
            }
            
            SwiftyBeaver.info("开始注册: \(data.email)")
            
            // 验证注册数据
            guard data.isValid else {
                SwiftyBeaver.error("注册数据无效")
                promise(.failure(.invalidEmail))
                return
            }
            
            // 检查邮箱是否已存在
            if self.mockUsers.contains(where: { $0.email == data.email }) {
                SwiftyBeaver.error("邮箱已存在: \(data.email)")
                promise(.failure(.emailAlreadyExists))
                return
            }
            
            // 模拟网络延迟
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
                let newUser = User(email: data.email, name: data.name)
                self.mockUsers.append(newUser)
                
                SwiftyBeaver.info("注册成功: \(newUser.email)")
                
                // 自动登录
                DispatchQueue.main.async {
                    self.authStateManager.login(user: newUser)
                }
                
                promise(.success(newUser))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, AuthError> {
        return Future<Void, AuthError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknownError("Service is nil")))
                return
            }
            
            SwiftyBeaver.info("开始登出")
            
            // 模拟网络延迟
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                DispatchQueue.main.async {
                    self.authStateManager.logout()
                }
                
                SwiftyBeaver.info("登出成功")
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func resetPassword(email: String) -> AnyPublisher<Void, AuthError> {
        return Future<Void, AuthError> { promise in
            SwiftyBeaver.info("发送密码重置邮件: \(email)")
            
            // 验证邮箱格式
            guard email.contains("@") else {
                SwiftyBeaver.error("无效的邮箱格式: \(email)")
                promise(.failure(.invalidEmail))
                return
            }
            
            // 模拟网络延迟
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                SwiftyBeaver.info("密码重置邮件发送成功")
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getCurrentUser() -> User? {
        return authStateManager.currentUser
    }
    
    // MARK: - Helper Methods
    private func validateCredentials(_ credentials: LoginCredentials) -> Bool {
        // 模拟凭据验证逻辑
        // 在实际应用中，这里应该调用后端API进行验证
        
        // 简单的测试凭据
        let validCredentials = [
            ("test@example.com", "123456"),
            ("admin@example.com", "admin123")
        ]
        
        return validCredentials.contains { email, password in
            email == credentials.email && password == credentials.password
        }
    }
}