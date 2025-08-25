//
//  HomeService.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/8/25.
//

import Foundation
import Combine
import SwiftyBeaver

// MARK: - Home Service Protocol
protocol HomeServiceProtocol {
    func fetchHomeItems() -> AnyPublisher<[HomeItem], HomeError>
    func fetchItemDetail(id: String) -> AnyPublisher<HomeItem, HomeError>
    func refreshData() -> AnyPublisher<[HomeItem], HomeError>
}

// MARK: - Home Service Implementation
class HomeService: HomeServiceProtocol {
    
    // MARK: - Properties
    private var mockItems: [HomeItem] = []
    
    // MARK: - Initialization
    init() {
        setupMockData()
    }
    
    // MARK: - Service Methods
    func fetchHomeItems() -> AnyPublisher<[HomeItem], HomeError> {
        return Future<[HomeItem], HomeError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknownError("Service is nil")))
                return
            }
            
            SwiftyBeaver.info("开始获取首页数据")
            
            // 模拟网络延迟
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                SwiftyBeaver.info("首页数据获取成功，共 \(self.mockItems.count) 项")
                promise(.success(self.mockItems))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchItemDetail(id: String) -> AnyPublisher<HomeItem, HomeError> {
        return Future<HomeItem, HomeError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknownError("Service is nil")))
                return
            }
            
            SwiftyBeaver.info("获取详情数据: \(id)")
            
            // 模拟网络延迟
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                if let item = self.mockItems.first(where: { $0.id == id }) {
                    SwiftyBeaver.info("详情数据获取成功")
                    promise(.success(item))
                } else {
                    SwiftyBeaver.error("未找到详情数据: \(id)")
                    promise(.failure(.loadDataFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func refreshData() -> AnyPublisher<[HomeItem], HomeError> {
        return Future<[HomeItem], HomeError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknownError("Service is nil")))
                return
            }
            
            SwiftyBeaver.info("开始刷新首页数据")
            
            // 模拟网络延迟
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
                // 添加一些新的模拟数据
                let newItem = HomeItem(
                    title: "新内容 \(self.mockItems.count + 1)",
                    subtitle: "刷新获取的新内容",
                    imageURL: "https://via.placeholder.com/300"
                )
                self.mockItems.insert(newItem, at: 0)
                
                SwiftyBeaver.info("首页数据刷新成功")
                promise(.success(self.mockItems))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    private func setupMockData() {
        mockItems = [
            HomeItem(
                title: "欢迎使用应用",
                subtitle: "这是一个MVVMC架构演示应用",
                imageURL: "https://via.placeholder.com/300"
            ),
            HomeItem(
                title: "功能介绍",
                subtitle: "集成了Swinject、Combine、Anchorage等技术",
                imageURL: "https://via.placeholder.com/300"
            ),
            HomeItem(
                title: "架构特点",
                subtitle: "模块化、协议导向、响应式编程",
                imageURL: "https://via.placeholder.com/300"
            ),
            HomeItem(
                title: "开发指南",
                subtitle: "如何添加新模块和功能",
                imageURL: "https://via.placeholder.com/300"
            ),
            HomeItem(
                title: "性能优化",
                subtitle: "内存管理和生命周期优化",
                imageURL: "https://via.placeholder.com/300"
            )
        ]
    }
}