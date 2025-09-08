//
//  DeviceControlViewController.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import UIKit
import Combine
import Anchorage

/// 设备控制视图控制器
class DeviceControlViewController: UIViewController, ViewControllable, Loggable {
    // MARK: - Properties
    
    // 视图模型
    private let viewModel: DeviceControlViewModel
    
    // UI元素
    private var deviceInfoLabel: UILabel!
    private var connectionStatusButton: UIButton!
    private var deviceStatusButton: UIButton!
    private var commandButtonsStackView: UIStackView!
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    
    // Combine订阅
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialization
    
    init(viewModel: DeviceControlViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        log.debug("设备控制视图控制器初始化完成")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupBindings()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 在视图将要出现时刷新数据
        viewModel.scanForDevices()
    }
    
    // MARK: - UI Setup
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 创建滚动视图
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        
        // 创建内容视图
        contentView = UIView()
        scrollView.addSubview(contentView)
        
        // 设备信息标签
        deviceInfoLabel = UILabel()
        deviceInfoLabel.text = "未选择设备"
        deviceInfoLabel.textAlignment = .center
        deviceInfoLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        contentView.addSubview(deviceInfoLabel)
        
        // 连接状态按钮
        connectionStatusButton = UIButton(type: .system)
        connectionStatusButton.setTitle("连接设备", for: .normal)
        connectionStatusButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        connectionStatusButton.backgroundColor = .systemBlue
        connectionStatusButton.setTitleColor(.white, for: .normal)
        connectionStatusButton.layer.cornerRadius = 8
        connectionStatusButton.addTarget(self, action: #selector(connectionButtonTapped), for: .touchUpInside)
        contentView.addSubview(connectionStatusButton)
        
        // 设备状态按钮
        deviceStatusButton = UIButton(type: .system)
        deviceStatusButton.setTitle("设备状态: 未知", for: .normal)
        deviceStatusButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        deviceStatusButton.backgroundColor = .systemGray
        deviceStatusButton.setTitleColor(.white, for: .normal)
        deviceStatusButton.layer.cornerRadius = 8
        deviceStatusButton.addTarget(self, action: #selector(statusButtonTapped), for: .touchUpInside)
        contentView.addSubview(deviceStatusButton)
        
        // 命令按钮堆栈视图
        commandButtonsStackView = UIStackView()
        commandButtonsStackView.axis = .vertical
        commandButtonsStackView.spacing = 12
        commandButtonsStackView.distribution = .fillEqually
        commandButtonsStackView.alignment = .fill
        contentView.addSubview(commandButtonsStackView)
        
        // 创建命令按钮
        createCommandButtons()
    }
    
    private func setupConstraints() {
        // 滚动视图约束
        scrollView.topAnchor == view.safeAreaLayoutGuide.topAnchor
        scrollView.leadingAnchor == view.leadingAnchor
        scrollView.trailingAnchor == view.trailingAnchor
        scrollView.bottomAnchor == view.bottomAnchor
        
        // 内容视图约束
        contentView.topAnchor == scrollView.topAnchor
        contentView.leadingAnchor == scrollView.leadingAnchor
        contentView.trailingAnchor == scrollView.trailingAnchor
        contentView.bottomAnchor == scrollView.bottomAnchor
        contentView.widthAnchor == scrollView.widthAnchor
        
        // 设备信息标签约束
        deviceInfoLabel.topAnchor == contentView.topAnchor + 20
        deviceInfoLabel.leadingAnchor == contentView.leadingAnchor + 20
        deviceInfoLabel.trailingAnchor == contentView.trailingAnchor - 20
        deviceInfoLabel.heightAnchor == 30
        
        // 连接状态按钮约束
        connectionStatusButton.topAnchor == deviceInfoLabel.bottomAnchor + 20
        connectionStatusButton.leadingAnchor == contentView.leadingAnchor + 20
        connectionStatusButton.trailingAnchor == contentView.trailingAnchor - 20
        connectionStatusButton.heightAnchor == 44
        
        // 设备状态按钮约束
        deviceStatusButton.topAnchor == connectionStatusButton.bottomAnchor + 20
        deviceStatusButton.leadingAnchor == contentView.leadingAnchor + 20
        deviceStatusButton.trailingAnchor == contentView.trailingAnchor - 20
        deviceStatusButton.heightAnchor == 44
        
        // 命令按钮堆栈视图约束
        commandButtonsStackView.topAnchor == deviceStatusButton.bottomAnchor + 30
        commandButtonsStackView.leadingAnchor == contentView.leadingAnchor + 20
        commandButtonsStackView.trailingAnchor == contentView.trailingAnchor - 20
        commandButtonsStackView.bottomAnchor == contentView.bottomAnchor - 30
    }
    
    func setupNavigationBar() {
        title = "设备控制"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "设备列表",
            style: .plain,
            target: self,
            action: #selector(deviceListButtonTapped)
        )
    }
    
    private func createCommandButtons() {
        // 清除现有的按钮
        commandButtonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 定义命令按钮
        let commands: [(title: String, type: CommandType)] = [
            ("开机", .powerOn),
            ("关机", .powerOff),
            ("开始清扫", .startCleaning),
            ("暂停清扫", .pauseCleaning),
            ("返回充电座", .returnToDock),
            ("获取状态", .getStatus),
            ("获取电量", .getBatteryLevel),
            ("Matter识别", .matterIdentify)
        ]
        
        // 创建按钮
        for command in commands {
            let button = UIButton(type: .system)
            button.setTitle(command.title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.backgroundColor = .systemGreen
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
            button.tag = command.type.rawValue.hashValue
            button.addTarget(self, action: #selector(commandButtonTapped(_:)), for: .touchUpInside)
            commandButtonsStackView.addArrangedSubview(button)
        }
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        // 绑定当前设备
        viewModel.$currentDevice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] device in
                self?.updateDeviceInfo(device)
            }
            .store(in: &cancellables)
        
        // 绑定连接状态
        viewModel.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.updateConnectionStatus(isConnected)
            }
            .store(in: &cancellables)
        
        // 绑定设备状态
        viewModel.$deviceStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.updateDeviceStatus(status)
            }
            .store(in: &cancellables)
        
        // 绑定加载状态
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.updateLoadingState(isLoading)
            }
            .store(in: &cancellables)
        
        // 绑定错误信息
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (message: String?) in
                if let message = message {
                    self?.showError(message)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Update Methods
    
    private func updateDeviceInfo(_ device: Device?) {
        if let device = device {
            var infoText = "\(device.name) (\(device.type.rawValue))"
            if device.connectionType == .matter {
                infoText += " [Matter]"
            }
            deviceInfoLabel.text = infoText
        } else {
            deviceInfoLabel.text = "未选择设备"
        }
    }
    
    private func updateConnectionStatus(_ isConnected: Bool) {
        if isConnected {
            connectionStatusButton.setTitle("断开连接", for: .normal)
            connectionStatusButton.backgroundColor = .systemRed
        } else {
            connectionStatusButton.setTitle("连接设备", for: .normal)
            connectionStatusButton.backgroundColor = .systemBlue
        }
        
        // 更新命令按钮的可用性
        for case let button as UIButton in commandButtonsStackView.arrangedSubviews {
            button.isEnabled = isConnected
            button.alpha = isConnected ? 1.0 : 0.5
        }
    }
    
    private func updateDeviceStatus(_ status: DeviceStatus) {
        deviceStatusButton.setTitle("设备状态: \(status.rawValue)", for: .normal)
        
        // 根据状态更新按钮颜色
        switch status {
        case .idle:
            deviceStatusButton.backgroundColor = .systemGreen
        case .working:
            deviceStatusButton.backgroundColor = .systemOrange
        case .charging:
            deviceStatusButton.backgroundColor = .systemBlue
        case .error:
            deviceStatusButton.backgroundColor = .systemRed
        default:
            deviceStatusButton.backgroundColor = .systemGray
        }
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            // 显示加载指示器
            showLoadingIndicator()
        } else {
            // 隐藏加载指示器
            hideLoadingIndicator()
        }
    }
    
    private func showLoadingIndicator() {
        // 在实际实现中，这里会显示加载指示器
        log.debug("显示加载指示器")
    }
    
    private func hideLoadingIndicator() {
        // 在实际实现中，这里会隐藏加载指示器
        log.debug("隐藏加载指示器")
    }
    
    private func showError(_ message: String) {
        log.error("显示错误: \(message)")
        
        // 显示错误提示
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func connectionButtonTapped() {
        if viewModel.isConnected {
            viewModel.disconnectDevice()
        } else {
            viewModel.connectToDevice()
        }
    }
    
    @objc private func statusButtonTapped() {
        viewModel.refreshDeviceStatus()
    }
    
    @objc private func commandButtonTapped(_ sender: UIButton) {
        // 根据按钮标签找到对应的命令类型
        // 在实际实现中，可能需要更好的映射方式
        let commands: [CommandType] = [
            .powerOn, .powerOff, .startCleaning, .pauseCleaning,
            .returnToDock, .getStatus, .getBatteryLevel, .matterIdentify
        ]
        
        if sender.tag < commands.count {
            let commandType = commands[sender.tag]
            viewModel.sendCommand(commandType)
        }
    }
    
    @objc private func deviceListButtonTapped() {
        log.debug("设备列表按钮被点击")
        // 在实际实现中，这里会导航到设备列表页面
    }
}