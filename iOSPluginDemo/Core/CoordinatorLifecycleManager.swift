//
//  CoordinatorLifecycleManager.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/8/25.
//

import UIKit
import Combine
import Swinject

// MARK: - Coordinator Lifecycle Manager Protocol
protocol CoordinatorLifecycleManager: AnyObject, Loggable {
    func createCoordinator<T: Coordinator>(_ type: T.Type, with container: Container) -> T
    func retainCoordinator(_ coordinator: Coordinator)
    func releaseCoordinator(_ coordinator: Coordinator)
    func cleanupAllCoordinators()
    func getActiveCoordinators() -> [Coordinator]
    func isCoordinatorActive(_ coordinator: Coordinator) -> Bool
}

// MARK: - Coordinator Registry
final class CoordinatorRegistry: CoordinatorLifecycleManager, Loggable {
    
    // MARK: - Properties
    private var activeCoordinators: Set<WeakCoordinatorWrapper> = []
    private let queue = DispatchQueue(label: "coordinator.registry", attributes: .concurrent)
    private var coordinatorMetrics: [String: CoordinatorMetrics] = [:]
    
    // MARK: - Singleton
    static let shared = CoordinatorRegistry()
    private init() {}
    
    // MARK: - Coordinator Lifecycle Management
    
    func createCoordinator<T: Coordinator>(_ type: T.Type, with container: Container) -> T {
        return queue.sync(flags: .barrier) {
            log.info("Creating coordinator of type: \(type)")
            
            // 检查是否已存在同类型的活跃 Coordinator
            if let existingCoordinator = findExistingCoordinator(of: type) {
                log.warning("Reusing existing coordinator of type: \(type)")
                return existingCoordinator
            }
            
            // 创建新的 Coordinator
            let coordinator = createNewCoordinator(type, with: container)
            
            // 注册到管理器
            retainCoordinator(coordinator)
            
            // 记录创建指标
            recordCreationMetrics(for: coordinator)
            
            return coordinator
        }
    }
    
    func retainCoordinator(_ coordinator: Coordinator) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            let wrapper = WeakCoordinatorWrapper(coordinator: coordinator)
            self.activeCoordinators.insert(wrapper)
            
            self.log.info("Retained coordinator: \(type(of: coordinator))")
            self.logActiveCoordinators()
        }
    }
    
    func releaseCoordinator(_ coordinator: Coordinator) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            let wrapper = WeakCoordinatorWrapper(coordinator: coordinator)
            self.activeCoordinators.remove(wrapper)
            
            self.log.info("Released coordinator: \(type(of: coordinator))")
            self.recordReleaseMetrics(for: coordinator)
            self.logActiveCoordinators()
        }
    }
    
    func cleanupAllCoordinators() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            self.log.info("Cleaning up all coordinators")
            
            // 清理所有 Coordinator
            for wrapper in self.activeCoordinators {
                if let coordinator = wrapper.coordinator {
                    coordinator.finish()
                }
            }
            
            self.activeCoordinators.removeAll()
            self.coordinatorMetrics.removeAll()
            
            self.log.info("All coordinators cleaned up")
        }
    }
    
    func getActiveCoordinators() -> [Coordinator] {
        return queue.sync {
            return activeCoordinators.compactMap { $0.coordinator }
        }
    }
    
    func isCoordinatorActive(_ coordinator: Coordinator) -> Bool {
        return queue.sync {
            let wrapper = WeakCoordinatorWrapper(coordinator: coordinator)
            return activeCoordinators.contains(wrapper)
        }
    }
    
    // MARK: - Helper Methods
    
    private func findExistingCoordinator<T: Coordinator>(of type: T.Type) -> T? {
        for wrapper in activeCoordinators {
            if let coordinator = wrapper.coordinator as? T {
                return coordinator
            }
        }
        return nil
    }
    
    private func createNewCoordinator<T: Coordinator>(_ type: T.Type, with container: Container) -> T {
        // 根据类型创建对应的 Coordinator
        switch type {
        case is AuthCoordinator.Type:
            let navigationController = UINavigationController()
            return AuthCoordinator(navigationController: navigationController, container: container) as! T
            
        case is MainCoordinator.Type:
            let tabBarController = UITabBarController()
            return MainCoordinator(tabBarController: tabBarController, container: container) as! T
            
        default:
            fatalError("Unsupported coordinator type: \(type)")
        }
    }
    
    private func recordCreationMetrics(for coordinator: Coordinator) {
        let typeName = String(describing: type(of: coordinator))
        let metrics = CoordinatorMetrics(
            typeName: typeName,
            creationTime: Date(),
            memoryFootprint: estimateMemoryFootprint(for: coordinator)
        )
        coordinatorMetrics[typeName] = metrics
    }
    
    private func recordReleaseMetrics(for coordinator: Coordinator) {
        let typeName = String(describing: type(of: coordinator))
        if var metrics = coordinatorMetrics[typeName] {
            metrics.releaseTime = Date()
            coordinatorMetrics[typeName] = metrics
            
            let lifetime = metrics.lifetime
            log.info("Coordinator \(typeName) lifetime: \(lifetime) seconds")
        }
    }
    
    private func estimateMemoryFootprint(for coordinator: Coordinator) -> Int {
        // 简单的内存占用估算
        return MemoryLayout.size(ofValue: coordinator)
    }
    
    private func logActiveCoordinators() {
        let activeCount = activeCoordinators.count
        let activeTypes = activeCoordinators.compactMap { wrapper in
            wrapper.coordinator.map { String(describing: type(of: $0)) }
        }
        
        log.info("Active coordinators count: \(activeCount)")
        log.info("Active coordinator types: \(activeTypes)")
    }
}

// MARK: - Weak Coordinator Wrapper
private class WeakCoordinatorWrapper: Hashable {
    weak var coordinator: Coordinator?
    private let objectIdentifier: ObjectIdentifier
    
    init(coordinator: Coordinator) {
        self.coordinator = coordinator
        self.objectIdentifier = ObjectIdentifier(coordinator)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(objectIdentifier)
    }
    
    static func == (lhs: WeakCoordinatorWrapper, rhs: WeakCoordinatorWrapper) -> Bool {
        return lhs.objectIdentifier == rhs.objectIdentifier
    }
}

// MARK: - Coordinator Metrics
private struct CoordinatorMetrics {
    let typeName: String
    let creationTime: Date
    let memoryFootprint: Int
    var releaseTime: Date?
    
    var lifetime: TimeInterval {
        guard let releaseTime = releaseTime else {
            return Date().timeIntervalSince(creationTime)
        }
        return releaseTime.timeIntervalSince(creationTime)
    }
}

// MARK: - Enhanced Coordinator Protocol
protocol EnhancedCoordinator: Coordinator, Loggable {
    var coordinatorId: UUID { get }
    var creationTime: Date { get }
    var isActive: Bool { get set }
    
    func cleanup()
    func reportMemoryUsage() -> Int
}

// MARK: - Enhanced Coordinator Base Class
class BaseEnhancedCoordinator: NSObject, EnhancedCoordinator, Loggable {
    
    // MARK: - Coordinator Protocol
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Enhanced Properties
    let coordinatorId = UUID()
    let creationTime = Date()
    var isActive: Bool = false
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        log.info("Created coordinator: \(type(of: self)) with ID: \(coordinatorId)")
    }
    
    // MARK: - Coordinator Methods
    func start() {
        isActive = true
        log.info("Started coordinator: \(type(of: self))")
    }
    
    func finish() {
        isActive = false
        cleanup()
        childCoordinators.removeAll()
        log.info("Finished coordinator: \(type(of: self))")
    }
    
    // MARK: - Enhanced Methods
    func cleanup() {
        // 子类重写此方法进行特定清理
        log.info("Cleaning up coordinator: \(type(of: self))")
    }
    
    func reportMemoryUsage() -> Int {
        return MemoryLayout.size(ofValue: self)
    }
    
    deinit {
        log.info("Deinitializing coordinator: \(type(of: self))")
    }
}
