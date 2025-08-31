//
//  DemoListViewModel.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/1/27.
//

import Foundation
import Combine
import UIKit

// MARK: - Demo List View Model
final class DemoListViewModel: ObservableObject, ViewModelable {
    
    // MARK: - Input
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let itemSelected = PassthroughSubject<DemoItem, Never>()
        let refreshTriggered = PassthroughSubject<Void, Never>()
        let searchTextChanged = PassthroughSubject<String, Never>()
    }
    
    // MARK: - Output
    struct Output {
        let sections: AnyPublisher<[DemoSection], Never>
        let isLoading: AnyPublisher<Bool, Never>
        let error: AnyPublisher<String?, Never>
        let showDemo: AnyPublisher<DemoItem, Never>
    }
    
    // MARK: - Properties
    let input = Input()
    let output: Output
    
    private let sectionsSubject = CurrentValueSubject<[DemoSection], Never>([])
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let errorSubject = CurrentValueSubject<String?, Never>(nil)
    private let showDemoSubject = PassthroughSubject<DemoItem, Never>()
    
    var cancellables = Set<AnyCancellable>()
    private var allDemos: [DemoItem] = []
    
    // MARK: - ViewModelable Requirements
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var log: Logger {
        return Logger(context: "DemoListViewModel")
    }
    
    // MARK: - Coordinator Actions
    var coordinatorActions: DemoCoordinatorActions?
    
    // MARK: - Initialization
    init() {
        output = Output(
            sections: sectionsSubject.eraseToAnyPublisher(),
            isLoading: isLoadingSubject.eraseToAnyPublisher(),
            error: errorSubject.eraseToAnyPublisher(),
            showDemo: showDemoSubject.eraseToAnyPublisher()
        )
        
        bindInputs()
        loadInitialData()
        setupBindings()
    }
    
    // MARK: - ViewModelable Implementation
    func setupBindings() {
        // Sync the internal subjects with @Published properties
        isLoadingSubject
            .assign(to: &$isLoading)
        
        errorSubject
            .assign(to: &$errorMessage)
    }
    
    // MARK: - Input Binding
    private func bindInputs() {
        // View Did Load
        input.viewDidLoad
            .sink { [weak self] in
                self?.loadDemoData()
            }
            .store(in: &cancellables)
        
        // Item Selected
        input.itemSelected
            .sink { [weak self] item in
                self?.handleItemSelection(item)
            }
            .store(in: &cancellables)
        
        // Refresh Triggered
        input.refreshTriggered
            .sink { [weak self] in
                self?.refreshData()
            }
            .store(in: &cancellables)
        
        // Search Text Changed
        input.searchTextChanged
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.filterDemos(with: searchText)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    private func loadInitialData() {
        allDemos = DemoDataProvider.getAllDemos()
        createSections()
    }
    
    private func loadDemoData() {
        isLoadingSubject.send(true)
        errorSubject.send(nil)
        
        // 模拟网络延迟
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.5) { [weak self] in
            DispatchQueue.main.async {
                self?.allDemos = DemoDataProvider.getAllDemos()
                self?.createSections()
                self?.isLoadingSubject.send(false)
            }
        }
    }
    
    private func refreshData() {
        loadDemoData()
    }
    
    private func createSections() {
        let groupedDemos = DemoDataProvider.getDemosByCategory()
        
        let sections = DemoCategory.allCases.compactMap { category -> DemoSection? in
            guard let demos = groupedDemos[category], !demos.isEmpty else { return nil }
            return DemoSection(category: category, items: demos)
        }
        
        sectionsSubject.send(sections)
    }
    
    // MARK: - Search & Filter
    private func filterDemos(with searchText: String) {
        if searchText.isEmpty {
            createSections()
            return
        }
        
        let filteredDemos = allDemos.filter { demo in
            demo.title.localizedCaseInsensitiveContains(searchText) ||
            demo.description.localizedCaseInsensitiveContains(searchText) ||
            demo.category.rawValue.localizedCaseInsensitiveContains(searchText)
        }
        
        let groupedDemos = Dictionary(grouping: filteredDemos) { $0.category }
        let sections = DemoCategory.allCases.compactMap { category -> DemoSection? in
            guard let demos = groupedDemos[category], !demos.isEmpty else { return nil }
            return DemoSection(category: category, items: demos)
        }
        
        sectionsSubject.send(sections)
    }
    
    // MARK: - Item Selection
    private func handleItemSelection(_ item: DemoItem) {
        switch item.action {
        case .longScreenshot:
            coordinatorActions?.showLongScreenshotDemo()
        case .scrollAnimation:
            coordinatorActions?.showScrollAnimationDemo()
        case .networkRequest:
            coordinatorActions?.showNetworkRequestDemo()
        case .dataStorage:
            coordinatorActions?.showDataStorageDemo()
        case .imageProcessing:
            coordinatorActions?.showImageProcessingDemo()
        case .socialSharing:
            coordinatorActions?.showSocialSharingDemo()
        case .qrCodeGeneration:
            coordinatorActions?.showQRCodeDemo()
        case .biometricAuth:
            coordinatorActions?.showBiometricAuthDemo()
        case .pushNotification:
            coordinatorActions?.showPushNotificationDemo()
        case .coreDataDemo:
            coordinatorActions?.showCoreDataDemo()
        case .custom(let action):
            action()
        }
        
        showDemoSubject.send(item)
    }
}

// MARK: - Demo Section Model
struct DemoSection {
    let category: DemoCategory
    let items: [DemoItem]
    
    var title: String {
        return category.rawValue
    }
}

// MARK: - Demo Coordinator Actions
protocol DemoCoordinatorActions {
    func showLongScreenshotDemo()
    func showScrollAnimationDemo()
    func showNetworkRequestDemo()
    func showDataStorageDemo()
    func showImageProcessingDemo()
    func showSocialSharingDemo()
    func showQRCodeDemo()
    func showBiometricAuthDemo()
    func showPushNotificationDemo()
    func showCoreDataDemo()
}
