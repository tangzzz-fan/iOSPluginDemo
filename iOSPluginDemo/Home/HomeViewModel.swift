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
    init(homeService: HomeServiceProtocol) {
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
        
        homeService.fetchHomeItems()
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