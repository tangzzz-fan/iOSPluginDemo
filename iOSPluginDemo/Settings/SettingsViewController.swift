//
//  SettingsViewController.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import UIKit
import Combine
import Anchorage

class SettingsViewController: UIViewController, ViewControllable, ViewControllerHelper, NavigationBarConfigurable {
    
    var cancellables = Set<AnyCancellable>()
    private let viewModel: SettingsViewModel
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "设置"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("退出登录", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        return activityIndicator
    }()
    
    // MARK: - Initialization
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        setupNavigationBar()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(logoutButton)
        logoutButton.addSubview(loadingView)
        
        // 设置约束
        titleLabel.topAnchor == view.safeAreaLayoutGuide.topAnchor + 60
        titleLabel.leadingAnchor == view.leadingAnchor + 20
        titleLabel.trailingAnchor == view.trailingAnchor - 20
        
        logoutButton.topAnchor == titleLabel.bottomAnchor + 100
        logoutButton.leadingAnchor == view.leadingAnchor + 20
        logoutButton.trailingAnchor == view.trailingAnchor - 20
        logoutButton.heightAnchor == 50
        
        loadingView.centerAnchors == logoutButton.centerAnchors
    }
    
    func bindViewModel() {
        // 绑定标题
        viewModel.$title
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.title = title
            }
            .store(in: &cancellables)
        
        // 绑定加载状态
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            }
            .store(in: &cancellables)
        
        // 绑定错误消息
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
            }
            .store(in: &cancellables)
    }
    
    func setupNavigationBar() {
        configureNavigationBar(title: "设置", prefersLargeTitles: true, largeTitleDisplayMode: .always)
    }
    
    // MARK: - Actions
    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(title: "退出登录", message: "您确定要退出登录吗？", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "退出", style: .destructive) { [weak self] _ in
            self?.viewModel.logout()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Helper Methods
    func showLoading() {
        loadingView.startAnimating()
        logoutButton.setTitle("", for: .normal)
        logoutButton.isEnabled = false
    }
    
    func hideLoading() {
        loadingView.stopAnimating()
        logoutButton.setTitle("退出登录", for: .normal)
        logoutButton.isEnabled = true
    }
} 
