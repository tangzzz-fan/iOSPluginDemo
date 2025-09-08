//
//  DeviceProvisioningViewController.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import UIKit
import Combine

/// 设备配网视图控制器
class DeviceProvisioningViewController: UIViewController, ViewControllable {
    // MARK: - Properties
    
    private let viewModel: DeviceProvisioningViewModel
    
    var cancellables = Set<AnyCancellable>()
    
    // UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "设备配网"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "请选择配网方式"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bluetoothButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("蓝牙配网", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let wifiButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("WiFi配网", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let qrCodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("扫码配网", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    init(viewModel: DeviceProvisioningViewModel) {
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
        setupBindings()
        setupNavigationBar()
    }
    
    // MARK: - UI Setup
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 添加UI元素
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(bluetoothButton)
        view.addSubview(wifiButton)
        view.addSubview(qrCodeButton)
        view.addSubview(activityIndicator)
        view.addSubview(statusLabel)
        
        // 设置约束
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            bluetoothButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            bluetoothButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            bluetoothButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            bluetoothButton.heightAnchor.constraint(equalToConstant: 50),
            
            wifiButton.topAnchor.constraint(equalTo: bluetoothButton.bottomAnchor, constant: 20),
            wifiButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            wifiButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            wifiButton.heightAnchor.constraint(equalToConstant: 50),
            
            qrCodeButton.topAnchor.constraint(equalTo: wifiButton.bottomAnchor, constant: 20),
            qrCodeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            qrCodeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            qrCodeButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.topAnchor.constraint(equalTo: qrCodeButton.bottomAnchor, constant: 40),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // 添加按钮事件
        bluetoothButton.addTarget(self, action: #selector(bluetoothButtonTapped), for: .touchUpInside)
        wifiButton.addTarget(self, action: #selector(wifiButtonTapped), for: .touchUpInside)
        qrCodeButton.addTarget(self, action: #selector(qrCodeButtonTapped), for: .touchUpInside)
    }
    
    func setupNavigationBar() {
        title = "设备配网"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        // 绑定加载状态
        viewModel.isLoadingPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (isLoading: Bool) in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        // 绑定当前状态
        viewModel.$currentState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateUI(for: state)
            }
            .store(in: &cancellables)
        
        // 绑定错误信息
        viewModel.errorMessagePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (errorMessage: String?) in
                if let errorMessage = errorMessage {
                    self?.showErrorAlert(message: errorMessage)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Updates
    
    private func updateUI(for state: ProvisioningState) {
        statusLabel.text = state.description
        
        // 根据状态更新UI
        switch state.type {
        case .idle:
            enableMethodButtons(true)
        case .selectingMethod:
            enableMethodButtons(true)
        case .bluetoothScanning, .wifiScanning, .qrCodeScanning:
            enableMethodButtons(false)
        case .success:
            showSuccessAlert()
        case .failed:
            enableMethodButtons(true)
        default:
            break
        }
    }
    
    private func enableMethodButtons(_ enabled: Bool) {
        bluetoothButton.isEnabled = enabled
        wifiButton.isEnabled = enabled
        qrCodeButton.isEnabled = enabled
        
        let alpha: CGFloat = enabled ? 1.0 : 0.6
        UIView.animate(withDuration: 0.2) {
            self.bluetoothButton.alpha = alpha
            self.wifiButton.alpha = alpha
            self.qrCodeButton.alpha = alpha
        }
    }
    
    // MARK: - Actions
    
    @objc private func bluetoothButtonTapped() {
        viewModel.selectBluetoothMethod()
    }
    
    @objc private func wifiButtonTapped() {
        viewModel.selectWiFiMethod()
    }
    
    @objc private func qrCodeButtonTapped() {
        viewModel.selectQRCodeMethod()
    }
    
    @objc private func cancelButtonTapped() {
        viewModel.cancelProvisioning()
        dismiss(animated: true)
    }
    
    // MARK: - Alert Methods
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "配网成功", message: "设备配网成功完成", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}