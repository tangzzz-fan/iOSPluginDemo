//
//  LongScreenshotDemoViewModel.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/1/27.
//

import Foundation
import Combine
import UIKit

// MARK: - Long Screenshot Demo View Model
final class LongScreenshotDemoViewModel: ObservableObject, ViewModelable {
    
    // MARK: - Input
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let shareButtonTapped = PassthroughSubject<UIScrollView, Never>()
        let refreshContent = PassthroughSubject<Void, Never>()
    }
    
    // MARK: - Output
    struct Output {
        let isLoading: AnyPublisher<Bool, Never>
        let errorMessage: AnyPublisher<String?, Never>
        let content: AnyPublisher<[DemoContentItem], Never>
    }
    
    // MARK: - Properties
    let input = Input()
    let output: Output
    
    private let screenshotService: ScreenshotGenerating
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let errorSubject = CurrentValueSubject<String?, Never>(nil)
    private let contentSubject = CurrentValueSubject<[DemoContentItem], Never>([])
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - ViewModelable Requirements
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var log: Logger {
        return Logger(context: "LongScreenshotDemoViewModel")
    }
    
    // MARK: - Coordinator Actions
    var coordinatorActions: LongScreenshotDemoCoordinatorActions?
    
    // MARK: - Initialization
    init(screenshotService: ScreenshotGenerating) {
        self.screenshotService = screenshotService
        
        output = Output(
            isLoading: isLoadingSubject.eraseToAnyPublisher(),
            errorMessage: errorSubject.eraseToAnyPublisher(),
            content: contentSubject.eraseToAnyPublisher()
        )
        
        bindInputs()
        loadContent()
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
                self?.loadContent()
            }
            .store(in: &cancellables)
        
        // Share Button Tapped
        input.shareButtonTapped
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoadingSubject.send(true)
                self?.errorSubject.send(nil)
            })
            .flatMap { [unowned self] scrollView in
                return self.screenshotService.generate(from: scrollView)
                    .receive(on: DispatchQueue.main)
                    .catch { [weak self] error -> Empty<UIImage, Never> in
                        self?.handleScreenshotError(error)
                        return Empty()
                    }
            }
            .sink { [weak self] image in
                self?.isLoadingSubject.send(false)
                self?.showShareSheet(with: image)
            }
            .store(in: &cancellables)
        
        // Refresh Content
        input.refreshContent
            .sink { [weak self] in
                self?.loadContent()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Content Loading
    private func loadContent() {
        let content = generateDemoContent()
        contentSubject.send(content)
    }
    
    private func generateDemoContent() -> [DemoContentItem] {
        return [
            DemoContentItem(
                type: .header,
                title: "长截图分享演示",
                content: "这个页面演示了如何生成完整的长截图。点击右上角的分享按钮，系统会自动截取整个页面内容并生成一张完整的图片。",
                image: UIImage(systemName: "camera.viewfinder")
            ),
            
            DemoContentItem(
                type: .section,
                title: "功能特点",
                content: "• 支持任意长度的滚动视图截图\n• 自动处理滚动视图状态恢复\n• 后台异步处理，不阻塞UI\n• 支持高分辨率图片生成\n• 完整的错误处理机制",
                image: UIImage(systemName: "star.fill")
            ),
            
            DemoContentItem(
                type: .section,
                title: "技术实现",
                content: "使用UIGraphicsImageRenderer进行高效渲染，通过Combine框架实现响应式编程，确保用户体验流畅。整个过程包括：\n\n1. 保存当前滚动状态\n2. 调整视图框架到内容大小\n3. 渲染完整内容到图像上下文\n4. 恢复原始滚动状态\n5. 返回生成的图片",
                image: UIImage(systemName: "gear")
            ),
            
            DemoContentItem(
                type: .code,
                title: "代码示例",
                content: """
func generate(from scrollView: UIScrollView) -> AnyPublisher<UIImage, ScreenshotError> {
    return Future<UIImage, ScreenshotError> { promise in
        DispatchQueue.global(qos: .userInitiated).async {
            // 保存原始状态
            let originalOffset = scrollView.contentOffset
            let originalFrame = scrollView.frame
            
            DispatchQueue.main.async {
                // 设置为内容大小
                scrollView.contentOffset = .zero
                scrollView.frame = CGRect(x: 0, y: 0, 
                    width: scrollView.contentSize.width,
                    height: scrollView.contentSize.height)
                
                // 渲染图像
                let renderer = UIGraphicsImageRenderer(size: scrollView.bounds.size)
                let image = renderer.image { context in
                    scrollView.layer.render(in: context.cgContext)
                }
                
                // 恢复状态
                scrollView.frame = originalFrame
                scrollView.contentOffset = originalOffset
                
                promise(.success(image))
            }
        }
    }
    .eraseToAnyPublisher()
}
""",
                image: UIImage(systemName: "curlybraces")
            ),
            
            DemoContentItem(
                type: .section,
                title: "使用场景",
                content: "• 分享完整的网页内容\n• 保存长对话记录\n• 导出完整的数据报告\n• 制作产品功能展示图\n• 创建教程截图\n• 备份重要信息",
                image: UIImage(systemName: "square.and.arrow.up")
            ),
            
            DemoContentItem(
                type: .section,
                title: "注意事项",
                content: "在使用长截图功能时，需要注意以下几点：\n\n• 确保滚动视图有有效的内容大小\n• 避免在截图过程中进行其他UI操作\n• 大内容可能会消耗较多内存\n• 建议在后台线程处理以保持UI响应",
                image: UIImage(systemName: "exclamationmark.triangle")
            ),
            
            DemoContentItem(
                type: .section,
                title: "性能优化",
                content: "为了确保最佳性能，系统采用了以下优化策略：\n\n• 异步处理避免阻塞主线程\n• 使用高效的图形渲染器\n• 智能内存管理\n• 错误恢复机制\n• 用户反馈提示",
                image: UIImage(systemName: "speedometer")
            ),
            
            DemoContentItem(
                type: .footer,
                title: "试试看！",
                content: "现在就试试点击右上角的分享按钮，生成这个完整页面的长截图吧！你可以将生成的图片保存到相册，或者分享给朋友。",
                image: UIImage(systemName: "hand.tap")
            )
        ]
    }
    
    // MARK: - Screenshot Handling
    private func showShareSheet(with image: UIImage) {
        // 通过coordinator显示分享界面，使用navigationBar作为sourceView
        coordinatorActions?.showShareSheet(with: image, from: UIView())
    }
    
    private func handleScreenshotError(_ error: ScreenshotError) {
        isLoadingSubject.send(false)
        errorSubject.send(error.localizedDescription)
    }
    

}

// MARK: - Demo Content Item
struct DemoContentItem {
    let type: ContentType
    let title: String
    let content: String
    let image: UIImage?
    
    enum ContentType {
        case header
        case section
        case code
        case footer
    }
}

// MARK: - Long Screenshot Demo Coordinator Actions
protocol LongScreenshotDemoCoordinatorActions {
    func showShareSheet(with image: UIImage, from sourceView: UIView)
    func dismissCurrentViewController()
}
