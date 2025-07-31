//
//  ForgotPasswordViewController.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import UIKit
import Combine
import Anchorage

class ForgotPasswordViewController: UIViewController, ViewControllable, ViewControllerHelper, NavigationBarConfigurable {
    
    var cancellables = Set<AnyCancellable>()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "请输入您的邮箱地址"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("发送重置邮件", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "我们将向您的邮箱发送密码重置链接"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(descriptionLabel)
        view.addSubview(emailTextField)
        view.addSubview(submitButton)
        
        descriptionLabel.topAnchor == view.safeAreaLayoutGuide.topAnchor + 60
        descriptionLabel.leadingAnchor == view.leadingAnchor + 20
        descriptionLabel.trailingAnchor == view.trailingAnchor - 20
        
        emailTextField.topAnchor == descriptionLabel.bottomAnchor + 40
        emailTextField.leadingAnchor == view.leadingAnchor + 20
        emailTextField.trailingAnchor == view.trailingAnchor - 20
        emailTextField.heightAnchor == 50
        
        submitButton.topAnchor == emailTextField.bottomAnchor + 32
        submitButton.leadingAnchor == view.leadingAnchor + 20
        submitButton.trailingAnchor == view.trailingAnchor - 20
        submitButton.heightAnchor == 50
    }
    
    func bindViewModel() {
        // 暂时不需要绑定
    }
    
    func setupNavigationBar() {
        configureNavigationBar(title: "忘记密码", prefersLargeTitles: false, largeTitleDisplayMode: .never)
    }
    
    @objc private func submitButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty else {
            showError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "请输入邮箱地址"]))
            return
        }
        
        // 模拟发送重置邮件
        submitButton.setTitle("发送中...", for: .normal)
        submitButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.submitButton.setTitle("发送重置邮件", for: .normal)
            self.submitButton.isEnabled = true
            self.showAlert(title: "发送成功", message: "重置邮件已发送到您的邮箱")
        }
    }
}

extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        submitButtonTapped()
        return true
    }
} 