//
//  HomeViewModel.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import Foundation
import Combine
import SwiftyBeaver

// MARK: - Home View Model
class HomeViewModel: NSObject, ViewModelable, ViewModelErrorHandling {
    
    // MARK: - Properties
    var cancellables = Set<AnyCancellable>()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var title: String = "首页"
    @Published var items: [HomeItem] = []
    
    // MARK: - Services
    private let homeService: HomeServiceProtocol
    
    // MARK: - Initialization
    init(homeService: HomeServiceProtocol = HomeService()) {
        self.homeService = homeService
        super.init()
        setupBindings()
    }
    
    // MARK: - Setup
    func setupBindings() {
        // 监听错误消息
        $errorMessage
            .compactMap { $0 }
            .sink { [weak self] errorMessage in
                self?.log.warning("Error message: \(errorMessage)")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    func loadData() {
        setLoading(true)
        clearError()
        
        homeService.fetchHomeData()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.setLoading(false)
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] items in
                    self?.items = items
                }
            )
            .store(in: &cancellables)
    }
    
    func refreshData() {
        loadData()
    }
    
    func selectItem(_ item: HomeItem) {
        log.info("Selected item: \(item.title)")
        // 处理项目选择逻辑
    }
}

// MARK: - Home Item Model
struct HomeItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageURL: String?
}

// MARK: - Home Service Protocol
protocol HomeServiceProtocol {
    func fetchHomeData() -> AnyPublisher<[HomeItem], Error>
}

// MARK: - Home Service Implementation
class HomeService: HomeServiceProtocol {
    private let log = SwiftyBeaver.self
    
    func fetchHomeData() -> AnyPublisher<[HomeItem], Error> {
        // 模拟网络请求
        return Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                let items = [
                    HomeItem(title: "项目 1", subtitle: "这是第一个项目", imageURL: nil),
                    HomeItem(title: "项目 2", subtitle: "这是第二个项目", imageURL: nil),
                    HomeItem(title: "项目 3", subtitle: "这是第三个项目", imageURL: nil)
                ]
                promise(.success(items))
            }
        }
        .eraseToAnyPublisher()
    }
} 