//
//  BaseModels.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/8/25.
//

import Foundation

// MARK: - User Model
struct User: Codable, Identifiable, Equatable {
    let id: String
    let email: String
    let name: String
    let avatarURL: String?
    let createdAt: Date
    
    init(id: String = UUID().uuidString, email: String, name: String, avatarURL: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.email = email
        self.name = name
        self.avatarURL = avatarURL
        self.createdAt = createdAt
    }
}

// MARK: - Home Item Model
struct HomeItem: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String?
    let imageURL: String?
    let createdAt: Date
    
    init(id: String = UUID().uuidString, title: String, subtitle: String? = nil, imageURL: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.createdAt = createdAt
    }
}

// MARK: - Login Credentials
struct LoginCredentials {
    let email: String
    let password: String
    
    var isValid: Bool {
        return !email.isEmpty && !password.isEmpty && email.contains("@")
    }
}

// MARK: - Registration Data
struct RegistrationData {
    let name: String
    let email: String
    let password: String
    let confirmPassword: String
    
    var isValid: Bool {
        return !name.isEmpty && 
               !email.isEmpty && 
               email.contains("@") &&
               !password.isEmpty && 
               password.count >= 6 &&
               password == confirmPassword
    }
}

// MARK: - Error Types
enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case networkError(String)
    case userNotFound
    case emailAlreadyExists
    case invalidEmail
    case weakPassword
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "用户名或密码错误"
        case .networkError(let message):
            return "网络错误: \(message)"
        case .userNotFound:
            return "用户不存在"
        case .emailAlreadyExists:
            return "邮箱已存在"
        case .invalidEmail:
            return "无效的邮箱格式"
        case .weakPassword:
            return "密码至少需要6位字符"
        case .unknownError(let message):
            return "未知错误: \(message)"
        }
    }
}

enum HomeError: Error, LocalizedError {
    case loadDataFailed
    case noInternetConnection
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .loadDataFailed:
            return "加载数据失败"
        case .noInternetConnection:
            return "无网络连接"
        case .unknownError(let message):
            return "未知错误: \(message)"
        }
    }
}