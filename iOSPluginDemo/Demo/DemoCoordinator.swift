//
//  DemoCoordinator.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/1/27.
//

import UIKit
import Swinject
import SwiftyBeaver

// MARK: - Demo Coordinator
final class DemoCoordinator: Coordinator {
    
    // MARK: - Properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let container: Container
    
    // MARK: - Initialization
    init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
    }
    
    // MARK: - Coordinator
    func start() {
        showDemoList()
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
    
    // MARK: - Navigation
    private func showDemoList() {
        guard let viewModel = container.resolve(DemoListViewModel.self) else {
            SwiftyBeaver.error("无法解析 DemoListViewModel")
            return
        }
        
        // 设置 coordinator actions
        viewModel.coordinatorActions = self
        
        let viewController = DemoListViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: - Demo Coordinator Actions
extension DemoCoordinator: DemoCoordinatorActions {
    
    func showLongScreenshotDemo() {
        SwiftyBeaver.info("显示长截图演示")
        showLongScreenshotDemoViewController()
    }
    
    func showScrollAnimationDemo() {
        SwiftyBeaver.info("显示滚动动画演示")
        showComingSoonAlert(for: "滚动动画演示")
    }
    
    func showNetworkRequestDemo() {
        SwiftyBeaver.info("显示网络请求演示")
        showComingSoonAlert(for: "网络请求演示")
    }
    
    func showDataStorageDemo() {
        SwiftyBeaver.info("显示数据存储演示")
        showComingSoonAlert(for: "数据存储演示")
    }
    
    func showImageProcessingDemo() {
        SwiftyBeaver.info("显示图像处理演示")
        showComingSoonAlert(for: "图像处理演示")
    }
    
    func showSocialSharingDemo() {
        SwiftyBeaver.info("显示社交分享演示")
        showComingSoonAlert(for: "社交分享演示")
    }
    
    func showQRCodeDemo() {
        SwiftyBeaver.info("显示二维码演示")
        showComingSoonAlert(for: "二维码演示")
    }
    
    func showBiometricAuthDemo() {
        SwiftyBeaver.info("显示生物识别演示")
        showComingSoonAlert(for: "生物识别演示")
    }
    
    func showPushNotificationDemo() {
        SwiftyBeaver.info("显示推送通知演示")
        showComingSoonAlert(for: "推送通知演示")
    }
    
    func showCoreDataDemo() {
        SwiftyBeaver.info("显示CoreData演示")
        showComingSoonAlert(for: "CoreData演示")
    }
    
    // MARK: - Private Methods
    private func showLongScreenshotDemoViewController() {
        // 创建长截图演示页面
        guard let screenshotService = container.resolve(ScreenshotGenerating.self) else {
            SwiftyBeaver.error("无法解析 ScreenshotGenerating 服务")
            showAlert(title: "错误", message: "无法加载截图服务")
            return
        }
        
        let viewModel = LongScreenshotDemoViewModel(screenshotService: screenshotService)
        let viewController = LongScreenshotDemoViewController(viewModel: viewModel)
        
        // 设置 coordinator actions
        viewModel.coordinatorActions = self
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showComingSoonAlert(for feature: String) {
        let alert = UIAlertController(
            title: "即将推出",
            message: "\(feature) 功能正在开发中，敬请期待！",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        navigationController.present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        navigationController.present(alert, animated: true)
    }
}

// MARK: - Long Screenshot Demo Coordinator Actions
extension DemoCoordinator: LongScreenshotDemoCoordinatorActions {
    
    func showShareSheet(with image: UIImage, from sourceView: UIView) {
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        // iPad support
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = navigationController.navigationBar
            popover.sourceRect = navigationController.navigationBar.bounds
        }
        
        navigationController.present(activityViewController, animated: true)
    }
    
    func dismissCurrentViewController() {
        navigationController.popViewController(animated: true)
    }
}
