//
//  AuthViewController.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import UIKit
import Combine
import Anchorage

// MARK: - Auth View Controller
class AuthViewController: UIViewController, ViewControllable, ViewControllerHelper, NavigationBarConfigurable {
    
    // MARK: - Properties
    var cancellables = Set<AnyCancellable>()
    private let viewModel: AuthViewModel
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "欢迎回来"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "请登录您的账户"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "邮箱地址"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .next
        textField.delegate = self
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "密码"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("登录", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("忘记密码？", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(forgotPasswordButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("没有账户？立即注册", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        return activityIndicator
    }()
    
    // MARK: - Initialization
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.checkAuthStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Setup
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 添加子视图
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(logoImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(emailTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(loginButton)
        contentView.addSubview(forgotPasswordButton)
        contentView.addSubview(registerButton)
        loginButton.addSubview(loadingView)
        
        // 设置约束
        scrollView.edgeAnchors == view.safeAreaLayoutGuide.edgeAnchors
        
        contentView.edgeAnchors == scrollView.edgeAnchors
        contentView.widthAnchor == scrollView.widthAnchor
        
        logoImageView.topAnchor == contentView.topAnchor + 60
        logoImageView.centerXAnchor == contentView.centerXAnchor
        logoImageView.widthAnchor == 80
        logoImageView.heightAnchor == 80
        
        titleLabel.topAnchor == logoImageView.bottomAnchor + 30
        titleLabel.leadingAnchor == contentView.leadingAnchor + 20
        titleLabel.trailingAnchor == contentView.trailingAnchor - 20
        
        subtitleLabel.topAnchor == titleLabel.bottomAnchor + 8
        subtitleLabel.leadingAnchor == contentView.leadingAnchor + 20
        subtitleLabel.trailingAnchor == contentView.trailingAnchor - 20
        
        emailTextField.topAnchor == subtitleLabel.bottomAnchor + 40
        emailTextField.leadingAnchor == contentView.leadingAnchor + 20
        emailTextField.trailingAnchor == contentView.trailingAnchor - 20
        emailTextField.heightAnchor == 50
        
        passwordTextField.topAnchor == emailTextField.bottomAnchor + 16
        passwordTextField.leadingAnchor == contentView.leadingAnchor + 20
        passwordTextField.trailingAnchor == contentView.trailingAnchor - 20
        passwordTextField.heightAnchor == 50
        
        loginButton.topAnchor == passwordTextField.bottomAnchor + 32
        loginButton.leadingAnchor == contentView.leadingAnchor + 20
        loginButton.trailingAnchor == contentView.trailingAnchor - 20
        loginButton.heightAnchor == 50
        
        loadingView.centerAnchors == loginButton.centerAnchors
        
        forgotPasswordButton.topAnchor == loginButton.bottomAnchor + 16
        forgotPasswordButton.centerXAnchor == contentView.centerXAnchor
        
        registerButton.topAnchor == forgotPasswordButton.bottomAnchor + 16
        registerButton.centerXAnchor == contentView.centerXAnchor
        registerButton.bottomAnchor == contentView.bottomAnchor - 40
        
        // 设置默认值方便测试
        setupDefaultValues()
    }
    
    func bindViewModel() {
        // 绑定标题
        viewModel.$title
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.title = title
            }
            .store(in: &cancellables)
        
        // 绑定邮箱输入
        emailTextField.textPublisher
            .assign(to: \.email, on: viewModel)
            .store(in: &cancellables)
        
        // 绑定密码输入
        passwordTextField.textPublisher
            .assign(to: \.password, on: viewModel)
            .store(in: &cancellables)
        
        // 绑定登录按钮状态
        viewModel.$isLoginEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.loginButton.isEnabled = isEnabled
                self?.loginButton.alpha = isEnabled ? 1.0 : 0.6
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
        
        // 绑定登录成功
        viewModel.$isLoggedIn
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleLoginSuccess()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Default Values Setup
    private func setupDefaultValues() {
        // 设置默认的测试账号和密码
        emailTextField.text = "test@example.com"
        passwordTextField.text = "123456"
        
        // 通知 ViewModel 更新输入值
        viewModel.email = "test@example.com"
        viewModel.password = "123456"
    }
    
    func setupNavigationBar() {
        configureNavigationBar(title: "登录", prefersLargeTitles: false, largeTitleDisplayMode: .never)
        
        // 添加关闭按钮（用于模态展示）
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        closeButton.tintColor = .systemGray
        navigationItem.leftBarButtonItem = closeButton
    }
    
    // MARK: - Actions
    @objc private func loginButtonTapped() {
        viewModel.login()
    }
    
    @objc private func forgotPasswordButtonTapped() {
        guard let coordinator = findCoordinator() as? AuthCoordinator else { return }
        coordinator.showForgotPassword()
    }
    
    @objc private func registerButtonTapped() {
        guard let coordinator = findCoordinator() as? AuthCoordinator else { return }
        coordinator.showRegistration()
    }
    
    @objc private func closeButtonTapped() {
        // 通过协调器关闭登录界面
        guard let coordinator = findCoordinator() as? AuthCoordinator else { return }
        coordinator.dismissAuth()
    }
    
    // MARK: - Helper Methods
    func showLoading() {
        loadingView.startAnimating()
        loginButton.setTitle("", for: .normal)
    }
    
    func hideLoading() {
        loadingView.stopAnimating()
        loginButton.setTitle("登录", for: .normal)
    }
    
    private func handleLoginSuccess() {
        // 在 MVVMC 架构中，通知已由 ViewModel 发送，这里只需要处理 UI 更新
        // 可以在这里添加一些 UI 反馈，比如显示成功动画等
    }
    
    private func findCoordinator() -> Coordinator? {
        var parent = parent
        while parent != nil {
            if let navigationController = parent as? UINavigationController,
               let coordinator = navigationController.delegate as? Coordinator {
                return coordinator
            }
            parent = parent?.parent
        }
        return nil
    }
}

// MARK: - UITextFieldDelegate
extension AuthViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            if viewModel.isLoginEnabled {
                viewModel.login()
            }
        }
        return true
    }
}

// MARK: - UITextField Publisher Extension
extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextField }
            .map { $0.text ?? "" }
            .eraseToAnyPublisher()
    }
} 
