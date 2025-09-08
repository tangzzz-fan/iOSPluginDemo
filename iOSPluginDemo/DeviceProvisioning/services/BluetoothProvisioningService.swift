//
//  BluetoothProvisioningService.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import Foundation
import Combine
import CoreBluetooth

/// 蓝牙配网服务实现
class BluetoothProvisioningService: NSObject, BluetoothProvisioningServiceProtocol, Loggable {
    // MARK: - Properties
    
    private var centralManager: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var discoveredDevices: [ProvisioningDevice] = []
    
    // Publisher subjects for events
    private let deviceDiscoverySubject = PassthroughSubject<ProvisioningDevice, Error>()
    private let connectionSubject = PassthroughSubject<Bool, Error>()
    private let provisioningSubject = PassthroughSubject<ProvisioningServiceResult, Error>()
    
    // Current provisioning operation
    private var currentProvisioningCancellable: AnyCancellable?
    private var currentScanCancellable: AnyCancellable?
    private var currentConnectionCancellable: AnyCancellable?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupCentralManager()
        log.debug("蓝牙配网服务初始化完成")
    }
    
    private func setupCentralManager() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - BluetoothProvisioningServiceProtocol Implementation
    
    /// 扫描蓝牙设备
    /// - Returns: 用于接收扫描结果的Publisher
    func scanForDevices() -> AnyPublisher<[ProvisioningDevice], Error> {
        log.debug("开始扫描蓝牙设备")
        
        guard let centralManager = centralManager else {
            return Fail(error: ProvisioningError.bluetoothNotAvailable)
                .eraseToAnyPublisher()
        }
        
        // 重置已发现的设备列表
        discoveredDevices.removeAll()
        
        // 检查蓝牙状态
        switch centralManager.state {
        case .poweredOn:
            // 开始扫描
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            log.info("蓝牙扫描已启动")
        case .poweredOff:
            log.error("蓝牙已关闭")
            return Fail(error: ProvisioningError.bluetoothPoweredOff)
                .eraseToAnyPublisher()
        case .unauthorized:
            log.error("蓝牙未授权")
            return Fail(error: ProvisioningError.bluetoothUnauthorized)
                .eraseToAnyPublisher()
        case .unsupported:
            log.error("设备不支持蓝牙")
            return Fail(error: ProvisioningError.bluetoothUnsupported)
                .eraseToAnyPublisher()
        default:
            log.error("蓝牙状态未知: \(centralManager.state.rawValue)")
            return Fail(error: ProvisioningError.bluetoothUnknownState)
                .eraseToAnyPublisher()
        }
        
        // 返回一个可以发送多个设备发现事件的Publisher
        return deviceDiscoverySubject
            .collect()
            .map { devices in
                self.log.debug("扫描到 \(devices.count) 个设备")
                return devices
            }
            .timeout(.seconds(30), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// 连接蓝牙设备
    /// - Parameter device: 要连接的设备
    /// - Returns: 用于接收连接结果的Publisher
    func connect(to device: ProvisioningDevice) -> AnyPublisher<Bool, Error> {
        log.debug("尝试连接设备: \(device.name)")
        
        guard let centralManager = centralManager else {
            return Fail(error: ProvisioningError.bluetoothNotAvailable)
                .eraseToAnyPublisher()
        }
        
        // 在实际实现中，我们需要通过设备ID找到对应的CBPeripheral
        // 这里简化处理，假设我们已经有了peripheral对象
        guard let peripheral = self.peripheral else {
            log.error("未找到要连接的外围设备")
            return Fail(error: ProvisioningError.deviceNotFound)
                .eraseToAnyPublisher()
        }
        
        // 连接设备
        centralManager.connect(peripheral, options: nil)
        
        // 返回连接结果的Publisher
        return connectionSubject
            .timeout(.seconds(30), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// 开始配网
    /// - Parameters:
    ///   - device: 要配网的设备
    ///   - config: 配网配置
    /// - Returns: 用于接收配网结果的Publisher
    func startProvisioning(for device: ProvisioningDevice, with config: ProvisioningConfiguration) -> AnyPublisher<ProvisioningServiceResult, Error> {
        log.debug("开始蓝牙配网: \(device.name)")
        
        // 在实际实现中，这里会通过蓝牙向设备发送配网信息
        // 包括WiFi名称、密码等
        
        // 模拟配网过程
        return Future<ProvisioningServiceResult, Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
                // 模拟配网成功
                let provisionedDevice = ProvisioningDevice(
                    id: device.id,
                    name: config.deviceName ?? device.name,
                    type: device.type,
                    isProvisioned: true,
                    supportedMethods: device.supportedMethods
                )
                
                self.log.info("蓝牙配网成功: \(provisionedDevice.name)")
                promise(.success(.success(provisionedDevice)))
            }
        }
        .timeout(.seconds(Int(config.timeout)), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    /// 取消配网
    func cancelProvisioning() {
        log.debug("取消蓝牙配网")
        
        // 停止扫描
        centralManager?.stopScan()
        
        // 断开连接
        if let peripheral = peripheral, peripheral.state == .connected {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
        
        // 发送取消信号
        deviceDiscoverySubject.send(completion: .finished)
        connectionSubject.send(completion: .finished)
        provisioningSubject.send(completion: .finished)
    }
    
    /// 检查服务是否可用
    /// - Returns: 服务是否可用
    func isServiceAvailable() -> Bool {
        guard let centralManager = centralManager else { return false }
        return centralManager.state == .poweredOn
    }
}

// MARK: - CBCentralManagerDelegate

extension BluetoothProvisioningService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        log.debug("蓝牙状态更新: \(central.state.rawValue)")
        
        switch central.state {
        case .poweredOn:
            log.info("蓝牙已开启")
        case .poweredOff:
            log.warning("蓝牙已关闭")
        case .unauthorized:
            log.error("蓝牙未授权")
        case .unsupported:
            log.error("设备不支持蓝牙")
        default:
            log.warning("蓝牙状态未知: \(central.state.rawValue)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        log.debug("发现蓝牙设备: \(peripheral.name ?? "Unknown")")
        
        // 创建配网设备对象
        let device = ProvisioningDevice(
            id: peripheral.identifier.uuidString,
            name: peripheral.name ?? "Unknown Device",
            type: .vacuumCleaner, // 简化处理，实际应根据设备特征判断
            rssi: RSSI.intValue,
            supportedMethods: [.bluetooth]
        )
        
        // 添加到已发现设备列表
        if !discoveredDevices.contains(where: { $0.id == device.id }) {
            discoveredDevices.append(device)
            deviceDiscoverySubject.send(device)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log.info("蓝牙设备连接成功: \(peripheral.name ?? "Unknown")")
        self.peripheral = peripheral
        connectionSubject.send(true)
        connectionSubject.send(completion: .finished)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        log.error("蓝牙设备连接失败: \(peripheral.name ?? "Unknown")")
        if let error = error {
            connectionSubject.send(completion: .failure(error))
        } else {
            connectionSubject.send(false)
            connectionSubject.send(completion: .finished)
        }
    }
}

// MARK: - Provisioning Errors

enum ProvisioningError: Error, LocalizedError {
    case bluetoothNotAvailable
    case bluetoothPoweredOff
    case bluetoothUnauthorized
    case bluetoothUnsupported
    case bluetoothUnknownState
    case deviceNotFound
    case connectionTimeout
    case provisioningFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .bluetoothNotAvailable:
            return "蓝牙不可用"
        case .bluetoothPoweredOff:
            return "蓝牙已关闭"
        case .bluetoothUnauthorized:
            return "蓝牙未授权"
        case .bluetoothUnsupported:
            return "设备不支持蓝牙"
        case .bluetoothUnknownState:
            return "蓝牙状态未知"
        case .deviceNotFound:
            return "未找到设备"
        case .connectionTimeout:
            return "连接超时"
        case .provisioningFailed(let message):
            return "配网失败: \(message)"
        }
    }
}