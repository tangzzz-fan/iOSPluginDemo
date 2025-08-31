//
//  LongScreenshotDemoViewController.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/1/27.
//

import UIKit
import Combine
import Anchorage

// MARK: - Long Screenshot Demo View Controller
final class LongScreenshotDemoViewController: UIViewController, ViewControllable, NavigationBarConfigurable {
    
    // MARK: - Properties
    private let viewModel: LongScreenshotDemoViewModel
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemGroupedBackground
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var loadingOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.isHidden = true
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.startAnimating()
        
        let label = UILabel()
        label.text = "正在生成截图..."
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        
        let containerView = UIView()
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        containerView.layer.cornerRadius = 12
        
        view.addSubview(containerView)
        containerView.centerAnchors == view.centerAnchors
        containerView.widthAnchor == 200
        containerView.heightAnchor == 120
        
        containerView.addSubview(indicator)
        indicator.centerXAnchor == containerView.centerXAnchor
        indicator.topAnchor == containerView.topAnchor + 20
        
        containerView.addSubview(label)
        label.topAnchor == indicator.bottomAnchor + 16
        label.leadingAnchor == containerView.leadingAnchor + 16
        label.trailingAnchor == containerView.trailingAnchor - 16
        label.bottomAnchor == containerView.bottomAnchor - 16
        
        return view
    }()
    
    // MARK: - Data
    private var contentItems: [DemoContentItem] = []
    
    // MARK: - Initialization
    init(viewModel: LongScreenshotDemoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.input.viewDidLoad.send()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    // MARK: - ViewControllable Implementation
    func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "长截图演示"
        
        // Setup navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareButtonTapped)
        )
        
        // Setup scroll view
        view.addSubview(scrollView)
        scrollView.edgeAnchors == view.safeAreaLayoutGuide.edgeAnchors
        
        // Setup content stack view
        scrollView.addSubview(contentStackView)
        contentStackView.edgeAnchors == scrollView.edgeAnchors + UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        contentStackView.widthAnchor == scrollView.widthAnchor - 32
        
        // Setup loading overlay
        view.addSubview(loadingOverlay)
        loadingOverlay.edgeAnchors == view.edgeAnchors
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
    }
    
    // MARK: - Navigation Bar Configuration
    func configureNavigationBar() {
        setupNavigationBar()
    }
    
    func bindViewModel() {
        // Bind loading state
        viewModel.output.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.updateLoadingState(isLoading)
            }
            .store(in: &cancellables)
        
        // Bind error
        viewModel.output.errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showError(errorMessage)
            }
            .store(in: &cancellables)
        
        // Bind content
        viewModel.output.content
            .receive(on: DispatchQueue.main)
            .sink { [weak self] content in
                self?.updateContent(content)
            }
            .store(in: &cancellables)
        

    }
    
    // MARK: - UI Updates
    private func updateLoadingState(_ isLoading: Bool) {
        loadingOverlay.isHidden = !isLoading
        navigationItem.rightBarButtonItem?.isEnabled = !isLoading
    }
    
    private func updateContent(_ content: [DemoContentItem]) {
        contentItems = content
        createContentViews()
    }
    
    private func createContentViews() {
        // Clear existing content
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add content views
        for item in contentItems {
            let contentView = createContentView(for: item)
            contentStackView.addArrangedSubview(contentView)
        }
        
        // Add some bottom padding
        let spacer = UIView()
        spacer.heightAnchor == 50
        contentStackView.addArrangedSubview(spacer)
    }
    
    private func createContentView(for item: DemoContentItem) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemGroupedBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fill
        stackView.alignment = .fill
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: item.type == .header ? 24 : 18, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        
        // Icon (if available)
        if let image = item.image {
            let iconView = UIImageView(image: image)
            iconView.contentMode = .scaleAspectFit
            iconView.tintColor = item.type == .header ? .systemBlue : .secondaryLabel
            iconView.heightAnchor == 24
            
            let headerStackView = UIStackView(arrangedSubviews: [iconView, titleLabel])
            headerStackView.axis = .horizontal
            headerStackView.spacing = 12
            headerStackView.alignment = .center
            stackView.addArrangedSubview(headerStackView)
        } else {
            stackView.addArrangedSubview(titleLabel)
        }
        
        // Content
        let contentLabel = UILabel()
        contentLabel.text = item.content
        contentLabel.font = item.type == .code ? .monospacedSystemFont(ofSize: 14, weight: .regular) : .systemFont(ofSize: 16)
        contentLabel.textColor = item.type == .code ? .systemTeal : .secondaryLabel
        contentLabel.numberOfLines = 0
        
        if item.type == .code {
            let codeContainer = UIView()
            codeContainer.backgroundColor = .systemGray6
            codeContainer.layer.cornerRadius = 8
            
            codeContainer.addSubview(contentLabel)
            contentLabel.edgeAnchors == codeContainer.edgeAnchors + UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
            
            stackView.addArrangedSubview(codeContainer)
        } else {
            stackView.addArrangedSubview(contentLabel)
        }
        
        containerView.addSubview(stackView)
        stackView.edgeAnchors == containerView.edgeAnchors + UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        return containerView
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    

    
    // MARK: - Actions
    @objc private func shareButtonTapped() {
        // 直接生成长截图并分享
        viewModel.input.shareButtonTapped.send(scrollView)
    }
}

