import Foundation
import Combine

/// 设备控制视图模型
class DeviceControlViewModel: ViewModelable {
    // MARK: - Properties
    
    // 服务依赖
    private let commandService: DeviceCommandServiceProtocol
    private let stateManager: DeviceStateManagerProtocol
    
    // 当前设备
    @Published private(set) var currentDevice: Device?
    
    // 设备状态
    @Published private(set) var deviceStatus: DeviceStatus = .unknown
    
    // 连接状态
    @Published private(set) var isConnected: Bool = false
    
    // 错误信息
    @Published var errorMessage: String?
    
    // 加载状态
    @Published var isLoading: Bool = false
    
    // 命令执行状态
    @Published private(set) var isExecutingCommand: Bool = false
    
    // 设备列表
    @Published private(set) var devices: [Device] = []
    
    // Combine订阅
    internal var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialization
    
    init(commandService: DeviceCommandServiceProtocol, stateManager: DeviceStateManagerProtocol) {
        self.commandService = commandService
        self.stateManager = stateManager
        log.debug("设备控制视图模型初始化完成")
        
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    /// 设置当前设备
    /// - Parameter device: 设备
    func setCurrentDevice(_ device: Device) {
        log.debug("设置当前设备: \(device.name)")
        currentDevice = device
        
        // 更新设备状态
        if let status = stateManager.getDeviceStatus(for: device.id) {
            deviceStatus = status
        }
        
        // 订阅设备状态变化
        subscribeToDeviceStatusChanges(for: device.id)
    }
    
    /// 连接设备
    func connectToDevice() {
        guard let device = currentDevice else {
            log.warning("没有设置当前设备，无法连接")
            return
        }
        
        log.debug("连接设备: \(device.name)")
        isLoading = true
        errorMessage = nil
        
        // 在实际实现中，这里会调用连接管理器连接设备
        // 模拟连接过程
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = false
            self.isConnected = true
            self.log.info("设备连接成功: \(device.name)")
        }
    }
    
    /// 断开设备连接
    func disconnectDevice() {
        guard let device = currentDevice else {
            log.warning("没有设置当前设备，无法断开连接")
            return
        }
        
        log.debug("断开设备连接: \(device.name)")
        isLoading = true
        errorMessage = nil
        
        // 在实际实现中，这里会调用连接管理器断开设备连接
        // 模拟断开过程
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = false
            self.isConnected = false
            self.log.info("设备断开连接成功: \(device.name)")
        }
    }
    
    /// 发送控制命令
    /// - Parameter commandType: 命令类型
    func sendCommand(_ commandType: CommandType) {
        guard let device = currentDevice else {
            log.warning("没有设置当前设备，无法发送命令")
            return
        }
        
        log.debug("发送控制命令: \(commandType) 到设备: \(device.name)")
        isExecutingCommand = true
        errorMessage = nil
        
        // 创建控制命令
        let command = ControlCommand(
            deviceId: device.id,
            type: commandType
        )
        
        // 发送命令
        commandService.sendCommand(command)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                
                self.isExecutingCommand = false
                
                switch completion {
                case .finished:
                    self.log.info("命令发送成功: \(commandType)")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.log.error("命令发送失败: \(error)")
                }
            }, receiveValue: { [weak self] success in
                guard let self = self else { return }
                
                if success {
                    self.log.info("设备成功接收命令: \(commandType)")
                } else {
                    self.errorMessage = "设备未成功接收命令"
                    self.log.warning("设备未成功接收命令: \(commandType)")
                }
            })
            .store(in: &cancellables)
    }
    
    /// 扫描设备
    func scanForDevices() {
        log.debug("开始扫描设备")
        isLoading = true
        errorMessage = nil
        
        // 在实际实现中，这里会调用相应的服务扫描设备
        // 根据设备类型调用不同的扫描方法
        scanForBluetoothDevices()
    }
    
    /// 刷新设备状态
    func refreshDeviceStatus() {
        guard let device = currentDevice else {
            log.warning("没有设置当前设备，无法刷新状态")
            return
        }
        
        log.debug("刷新设备状态: \(device.name)")
        isLoading = true
        
        // 发送获取状态命令
        sendCommand(.getStatus)
    }
    
    // MARK: - Internal Methods
    
    /// 设置绑定
    internal func setupBindings() {
        // 在实际实现中，这里会设置各种绑定关系
        log.debug("设置视图模型绑定")
    }
    
    // MARK: - Private Methods
    
    /// 订阅设备状态变化
    /// - Parameter deviceId: 设备ID
    private func subscribeToDeviceStatusChanges(for deviceId: String) {
        stateManager.subscribeToDeviceStatusChanges(for: deviceId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                self.deviceStatus = status
                self.log.debug("设备状态更新: \(status)")
            }
            .store(in: &cancellables)
    }
    
    /// 扫描蓝牙设备
    private func scanForBluetoothDevices() {
        // 在实际实现中，这里会调用蓝牙服务扫描设备
        // 模拟扫描过程
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = false
            
            // 模拟扫描到的设备
            let mockDevices = [
                Device(id: "1", name: "扫地机器人-01", type: DeviceControlDeviceType.vacuumCleaner, rssi: -50, connectionType: ConnectionType.bluetooth, status: DeviceStatus.idle),
                Device(id: "2", name: "草地机器人-01", type: DeviceControlDeviceType.lawnMower, rssi: -60, connectionType: ConnectionType.bluetooth, status: DeviceStatus.idle),
                Device(id: "3", name: "泳池清洁机器人-01", type: DeviceControlDeviceType.poolCleaner, rssi: -70, connectionType: ConnectionType.bluetooth, status: DeviceStatus.idle),
                Device(id: "4", name: "Matter智能灯-01", type: DeviceControlDeviceType.smartLight, rssi: nil, ipAddress: "192.168.1.100", connectionType: ConnectionType.matter, status: DeviceStatus.idle)
            ]
            
            self.devices = mockDevices
            self.log.info("扫描到 \(mockDevices.count) 个设备")
        }
    }
}