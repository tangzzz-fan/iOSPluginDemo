//
//  ProfileViewController.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import UIKit
import Combine
import Anchorage

class ProfileViewController: UIViewController, ViewControllable, ViewControllerHelper, NavigationBarConfigurable {
    
    var cancellables = Set<AnyCancellable>()
    private let viewModel: ProfileViewModel
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "个人资料"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let avatarView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 50
        return view
    }()
    
    private let initialsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Initialization
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        bindViewModel()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 添加子视图
        [titleLabel, avatarView, nameLabel, emailLabel].forEach { view.addSubview($0) }
        avatarView.addSubview(initialsLabel)
        
        // 设置约束
        titleLabel.topAnchor == view.safeAreaLayoutGuide.topAnchor + 20
        titleLabel.leadingAnchor == view.leadingAnchor + 20
        titleLabel.trailingAnchor == view.trailingAnchor - 20
        
        avatarView.topAnchor == titleLabel.bottomAnchor + 40
        avatarView.centerXAnchor == view.centerXAnchor
        avatarView.widthAnchor == 100
        avatarView.heightAnchor == 100
        
        initialsLabel.centerAnchors == avatarView.centerAnchors
        
        nameLabel.topAnchor == avatarView.bottomAnchor + 20
        nameLabel.leadingAnchor == view.leadingAnchor + 20
        nameLabel.trailingAnchor == view.trailingAnchor - 20
        
        emailLabel.topAnchor == nameLabel.bottomAnchor + 8
        emailLabel.leadingAnchor == view.leadingAnchor + 20
        emailLabel.trailingAnchor == view.trailingAnchor - 20
    }
    
    func bindViewModel() {
        // 绑定用户名称
        viewModel.$displayName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.nameLabel.text = name.isEmpty ? "未登录" : name
            }
            .store(in: &cancellables)
        
        // 绑定用户邮箱
        viewModel.$displayEmail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] email in
                self?.emailLabel.text = email.isEmpty ? "请登录查看个人信息" : email
            }
            .store(in: &cancellables)
        
        // 绑定用户头像初始字母
        viewModel.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.initialsLabel.text = self?.viewModel.userInitials ?? "?"
            }
            .store(in: &cancellables)
        
        // 绑定加载状态
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                // 可以在这里显示加载指示器
                if isLoading {
                    self?.view.alpha = 0.7
                } else {
                    self?.view.alpha = 1.0
                }
            }
            .store(in: &cancellables)
    }
    
    func setupNavigationBar() {
        configureNavigationBar(title: "个人资料", prefersLargeTitles: true, largeTitleDisplayMode: .always)
    }
}