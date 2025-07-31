//
//  RegistrationViewController.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import UIKit
import Combine
import Anchorage

class RegistrationViewController: UIViewController, ViewControllable, ViewControllerHelper, NavigationBarConfigurable {
    
    var cancellables = Set<AnyCancellable>()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "姓名"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .words
        textField.returnKeyType = .next
        textField.delegate = self
        return textField
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
        textField.returnKeyType = .next
        textField.delegate = self
        return textField
    }()
    
    private lazy var confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "确认密码"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("注册", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(nameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(registerButton)
        
        nameTextField.topAnchor == view.safeAreaLayoutGuide.topAnchor + 60
        nameTextField.leadingAnchor == view.leadingAnchor + 20
        nameTextField.trailingAnchor == view.trailingAnchor - 20
        nameTextField.heightAnchor == 50
        
        emailTextField.topAnchor == nameTextField.bottomAnchor + 16
        emailTextField.leadingAnchor == view.leadingAnchor + 20
        emailTextField.trailingAnchor == view.trailingAnchor - 20
        emailTextField.heightAnchor == 50
        
        passwordTextField.topAnchor == emailTextField.bottomAnchor + 16
        passwordTextField.leadingAnchor == view.leadingAnchor + 20
        passwordTextField.trailingAnchor == view.trailingAnchor - 20
        passwordTextField.heightAnchor == 50
        
        confirmPasswordTextField.topAnchor == passwordTextField.bottomAnchor + 16
        confirmPasswordTextField.leadingAnchor == view.leadingAnchor + 20
        confirmPasswordTextField.trailingAnchor == view.trailingAnchor - 20
        confirmPasswordTextField.heightAnchor == 50
        
        registerButton.topAnchor == confirmPasswordTextField.bottomAnchor + 32
        registerButton.leadingAnchor == view.leadingAnchor + 20
        registerButton.trailingAnchor == view.trailingAnchor - 20
        registerButton.heightAnchor == 50
    }
    
    func bindViewModel() {
        // 暂时不需要绑定
    }
    
    func setupNavigationBar() {
        configureNavigationBar(title: "注册", prefersLargeTitles: false, largeTitleDisplayMode: .never)
    }
    
    @objc private func registerButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            showError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "请输入姓名"]))
            return
        }
        
        guard let email = emailTextField.text, !email.isEmpty, email.contains("@") else {
            showError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "请输入有效的邮箱地址"]))
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "请输入密码"]))
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, password == confirmPassword else {
            showError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "两次输入的密码不一致"]))
            return
        }
        
        // 模拟注册
        registerButton.setTitle("注册中...", for: .normal)
        registerButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.registerButton.setTitle("注册", for: .normal)
            self.registerButton.isEnabled = true
            self.showAlert(title: "注册成功", message: "账户创建成功，请登录")
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        } else if textField == confirmPasswordTextField {
            textField.resignFirstResponder()
            registerButtonTapped()
        }
        return true
    }
} 