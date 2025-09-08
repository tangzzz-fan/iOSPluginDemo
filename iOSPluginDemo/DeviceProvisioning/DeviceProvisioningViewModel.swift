//
//  DeviceProvisioningViewModel.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import Foundation
import Combine
import Swinject

/// 设备配网视图模型
class DeviceProvisioningViewModel: ViewModelable {
    // MARK: - Properties
    
    // ViewModelable properties
    var cancellables = Set<AnyCancellable>()
    var isLoading: Bool = false {
        didSet {
            log.debug("加载状态变更: \(isLoading)")
            isLoadingSubject.send(isLoading)
        }
    }
    var errorMessage: String? = nil {
        didSet {
            if let errorMessage = errorMessage {
                log.error("错误信息更新: \(errorMessage)")
            }
            errorMessageSubject.send(errorMessage)
        }
    }
    
    // 私有发布者
    private let isLoadingSubject = PassthroughSubject<Bool, Never>()
    private let errorMessageSubject = PassthroughSubject<String?, Never>()
    
    // 状态机
    private let stateMachine: ProvisioningStateMachineProtocol
    
    // 配网服务
    private let bluetoothService: BluetoothProvisioningServiceProtocol
    private let wifiService: WiFiProvisioningServiceProtocol
    private let qrCodeService: QRCodeProvisioningServiceProtocol
    
    // 当前选中的配网方式
    @Published private(set) var selectedMethod: ProvisioningMethodType?
    
    // 当前状态
    @Published private(set) var currentState: ProvisioningState
    
    // 扫描到的设备列表
    @Published private(set) var discoveredDevices: [ProvisioningDevice] = []
    
    // 扫描到的网络列表
    @Published private(set) var discoveredNetworks: [NetworkInfo] = []
    
    // 配网配置
    @Published private(set) var configuration: ProvisioningConfiguration
    
    // 当前配网设备
    @Published private(set) var currentDevice: ProvisioningDevice?
    
    // 配网结果
    @Published private(set) var provisioningResult: ProvisioningServiceResult?
    
    // MARK: - Initialization
    
    init(
        stateMachine: ProvisioningStateMachineProtocol,
        bluetoothService: BluetoothProvisioningServiceProtocol,
        wifiService: WiFiProvisioningServiceProtocol,
        qrCodeService: QRCodeProvisioningServiceProtocol
    ) {
        self.stateMachine = stateMachine
        self.bluetoothService = bluetoothService
        self.wifiService = wifiService
        self.qrCodeService = qrCodeService
        self.currentState = stateMachine.currentState
        self.configuration = ProvisioningConfiguration.default
        
        setupBindings()
        log.debug("设备配网视图模型初始化完成")
    }
    
    // MARK: - Public Methods
    
    /// 获取isLoading发布者
    func isLoadingPublisher() -> AnyPublisher<Bool, Never> {
        return isLoadingSubject.eraseToAnyPublisher()
    }
    
    /// 获取errorMessage发布者
    func errorMessagePublisher() -> AnyPublisher<String?, Never> {
        return errorMessageSubject.eraseToAnyPublisher()
    }
    
    /// 开始配网流程
    func startProvisioning() {
        log.info("开始配网流程")
        stateMachine.handleEvent(.startProvisioning)
    }
    
    /// 选择蓝牙配网方式
    func selectBluetoothMethod() {
        log.debug("选择蓝牙配网方式")
        selectedMethod = .bluetooth
        stateMachine.handleEvent(.selectBluetoothMethod)
        scanForBluetoothDevices()
    }
    
    /// 选择WiFi配网方式
    func selectWiFiMethod() {
        log.debug("选择WiFi配网方式")
        selectedMethod = .wifi
        stateMachine.handleEvent(.selectWiFiMethod)
        scanForWiFiNetworks()
    }
    
    /// 选择二维码配网方式
    func selectQRCodeMethod() {
        log.debug("选择二维码配网方式")
        selectedMethod = .qrCode
        stateMachine.handleEvent(.selectQRCodeMethod)
    }
    
    /// 扫描蓝牙设备
    func scanForBluetoothDevices() {
        log.debug("开始扫描蓝牙设备")
        setLoading(true)
        
        bluetoothService.scanForDevices()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.setLoading(false)
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] devices in
                    self?.discoveredDevices = devices
                    self?.log.debug("发现 \(devices.count) 个蓝牙设备")
                }
            )
            .store(in: &cancellables)
    }
    
    /// 扫描WiFi网络
    func scanForWiFiNetworks() {
        log.debug("开始扫描WiFi网络")
        setLoading(true)
        
        wifiService.scanForNetworks()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.setLoading(false)
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] networks in
                    self?.discoveredNetworks = networks
                    self?.log.debug("发现 \(networks.count) 个WiFi网络")
                }
            )
            .store(in: &cancellables)
    }
    
    /// 选择设备
    /// - Parameter device: 选中的设备
    func selectDevice(_ device: ProvisioningDevice) {
        log.debug("选择设备: \(device.name)")
        currentDevice = device
        stateMachine.handleEvent(.deviceFound(device))
    }
    
    /// 选择网络
    /// - Parameter network: 选中的网络
    func selectNetwork(_ network: NetworkInfo) {
        log.debug("选择网络: \(network.ssid)")
        stateMachine.handleEvent(.networkSelected(network.ssid))
    }
    
    /// 处理二维码数据
    /// - Parameter qrCodeData: 二维码数据
    func processQRCodeData(_ qrCodeData: String) {
        log.debug("处理二维码数据")
        setLoading(true)
        
        qrCodeService.processQRCodeData(qrCodeData)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.setLoading(false)
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] config in
                    self?.configuration = config
                    self?.stateMachine.handleEvent(.qrCodeScanned(qrCodeData))
                    self?.log.debug("二维码数据处理完成")
                }
            )
            .store(in: &cancellables)
    }
    
    /// 连接设备
    func connectToDevice() {
        log.debug("连接设备")
        guard let device = currentDevice else {
            handleError(ProvisioningViewModelError.noDeviceSelected)
            return
        }
        
        setLoading(true)
        
        switch selectedMethod {
        case .bluetooth:
            bluetoothService.connect(to: device)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        self?.setLoading(false)
                        if case .failure(let error) = completion {
                            self?.handleError(error)
                        }
                    },
                    receiveValue: { [weak self] connected in
                        if connected {
                            self?.stateMachine.handleEvent(.deviceConnected)
                            self?.log.info("蓝牙设备连接成功")
                        } else {
                            self?.handleError(ProvisioningViewModelError.connectionFailed)
                        }
                    }
                )
                .store(in: &cancellables)
                
        case .wifi:
            // WiFi连接需要网络和密码
            guard let ssid = configuration.ssid, let password = configuration.password else {
                handleError(ProvisioningViewModelError.missingWiFiCredentials)
                return
            }
            
            // 在实际实现中，我们可能需要先找到对应的NetworkInfo对象
            // 这里简化处理
            let network = NetworkInfo(ssid: ssid, security: .wpa2, signalStrength: 3)
            
            wifiService.connect(to: network, with: password)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        self?.setLoading(false)
                        if case .failure(let error) = completion {
                            self?.handleError(error)
                        }
                    },
                    receiveValue: { [weak self] connected in
                        if connected {
                            self?.stateMachine.handleEvent(.deviceConnected)
                            self?.log.info("WiFi网络连接成功")
                        } else {
                            self?.handleError(ProvisioningViewModelError.connectionFailed)
                        }
                    }
                )
                .store(in: &cancellables)
                
        case .qrCode:
            // 二维码配网不需要单独的连接步骤
            stateMachine.handleEvent(.deviceConnected)
            
        case .none:
            handleError(ProvisioningViewModelError.noMethodSelected)
        }
    }
    
    /// 开始配网
    func provisionDevice() {
        log.debug("开始配网")
        guard let device = currentDevice else {
            handleError(ProvisioningViewModelError.noDeviceSelected)
            return
        }
        
        setLoading(true)
        stateMachine.handleEvent(.provisioningProgress(0.0)) // 使用provisioningProgress替代provisioning
        
        let service: ProvisioningServiceProtocol
        switch selectedMethod {
        case .bluetooth:
            service = bluetoothService
        case .wifi:
            service = wifiService
        case .qrCode:
            service = qrCodeService
        case .none:
            handleError(ProvisioningViewModelError.noMethodSelected)
            return
        }
        
        service.startProvisioning(for: device, with: configuration)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.setLoading(false)
                    if case .failure(let error) = completion {
                        self?.stateMachine.handleEvent(.provisioningFailed(error))
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] result in
                    self?.provisioningResult = result
                    switch result {
                    case .success(let provisionedDevice):
                        self?.currentDevice = provisionedDevice
                        self?.stateMachine.handleEvent(.provisioningSuccess)
                        self?.log.info("设备配网成功: \(provisionedDevice.name)")
                    case .failure(let error):
                        self?.stateMachine.handleEvent(.provisioningFailed(error))
                        self?.handleError(error)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    /// 重试配网
    func retryProvisioning() {
        log.debug("重试配网")
        clearError()
        stateMachine.handleEvent(.retry)
    }
    
    /// 取消配网
    func cancelProvisioning() {
        log.debug("取消配网")
        clearError()
        stateMachine.handleEvent(.cancel)
        
        // 取消所有正在进行的服务操作
        bluetoothService.cancelProvisioning()
        wifiService.cancelProvisioning()
        qrCodeService.cancelProvisioning()
    }
    
    /// 完成配网
    func finishProvisioning() {
        log.debug("完成配网")
        stateMachine.handleEvent(.finish)
    }
    
    /// 更新配网配置
    /// - Parameter configuration: 新的配网配置
    func updateConfiguration(_ configuration: ProvisioningConfiguration) {
        log.debug("更新配网配置")
        self.configuration = configuration
    }
    
    /// 重置视图模型
    func reset() {
        log.debug("重置视图模型")
        stateMachine.reset()
        selectedMethod = nil
        discoveredDevices.removeAll()
        discoveredNetworks.removeAll()
        configuration = ProvisioningConfiguration.default
        currentDevice = nil
        provisioningResult = nil
        clearError()
    }
}

// MARK: - Provisioning Errors

enum ProvisioningViewModelError: Error, LocalizedError {
    case noMethodSelected
    case noDeviceSelected
    case missingWiFiCredentials
    case connectionFailed
    
    var errorDescription: String? {
        switch self {
        case .noMethodSelected:
            return "未选择配网方式"
        case .noDeviceSelected:
            return "未选择设备"
        case .missingWiFiCredentials:
            return "缺少WiFi凭证信息"
        case .connectionFailed:
            return "设备连接失败"
        }
    }
}