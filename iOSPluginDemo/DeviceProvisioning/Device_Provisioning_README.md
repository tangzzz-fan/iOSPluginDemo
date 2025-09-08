# 设备配网模块使用指南

## 简介

设备配网模块为智能家居设备（如扫地机器人）提供了完整的配网解决方案，支持三种配网方式：
1. 蓝牙配网
2. WiFi配网
3. 二维码配网

该模块基于状态机模式设计，遵循SOLID原则，完全集成到现有的MVVMC架构中。

## 架构设计

### 状态机模式

配网流程使用状态机管理，包含以下状态：
- Idle: 初始状态
- SelectingMethod: 选择配网方式
- BluetoothScanning: 蓝牙扫描设备
- BluetoothConnecting: 蓝牙连接设备
- BluetoothProvisioning: 蓝牙配网中
- WiFiScanning: WiFi扫描网络
- WiFiConnecting: WiFi连接网络
- WiFiProvisioning: WiFi配网中
- QRCodeScanning: 扫描二维码
- QRCodeProcessing: 处理二维码数据
- Provisioning: 配网进行中
- Success: 配网成功
- Failed: 配网失败
- Completed: 配网完成

### 组件结构

```
DeviceProvisioning/
├── DeviceProvisioningCoordinator.swift     # 协调器
├── DeviceProvisioningViewModel.swift       # 视图模型
├── views/                                  # 视图层
│   ├── DeviceProvisioningViewController.swift
│   ├── BluetoothProvisioningView.swift
│   ├── WiFiProvisioningView.swift
│   └── QRCodeProvisioningView.swift
├── models/                                 # 数据模型
│   ├── ProvisioningDevice.swift
│   ├── ProvisioningState.swift
│   └── ProvisioningConfiguration.swift
├── services/                               # 服务层
│   ├── ProvisioningService.swift
│   ├── BluetoothProvisioningService.swift
│   ├── WiFiProvisioningService.swift
│   └── QRCodeProvisioningService.swift
├── state/                                  # 状态机
│   ├── ProvisioningStateMachine.swift
│   └── ProvisioningStateProtocol.swift
└── DeviceProvisioningModule.swift          # 模块定义
```

## 使用方法

### 1. 启动配网流程

```swift
// 通过依赖注入获取协调器工厂
let coordinatorFactory = container.resolve(CoordinatorFactory.self)!

// 创建设备配网协调器
let deviceProvisioningCoordinator = coordinatorFactory.makeCoordinator(for: .deviceProvisioning)

// 启动配网流程
deviceProvisioningCoordinator.start()
```

### 2. 在现有流程中集成配网功能

```swift
// 在需要配网的地方（如设置页面），可以这样启动配网流程
@IBAction func provisionDeviceTapped(_ sender: UIButton) {
    // 通过依赖注入获取协调器工厂
    let coordinatorFactory = container.resolve(CoordinatorFactory.self)!
    
    // 创建设备配网协调器
    let deviceProvisioningCoordinator = coordinatorFactory.makeCoordinator(for: .deviceProvisioning)
    
    // 将配网协调器作为子协调器添加
    addChildCoordinator(deviceProvisioningCoordinator)
    
    // 启动配网流程
    deviceProvisioningCoordinator.start()
    
    // 导航到配网界面
    navigationController?.pushViewController(deviceProvisioningCoordinator.navigationController, animated: true)
}
```

### 3. 自定义配网配置

```swift
// 创建自定义配网配置
let config = ProvisioningConfiguration(
    ssid: "MyHomeWiFi",
    password: "MyPassword",
    deviceName: "MyVacuumCleaner",
    timeout: 120.0,
    maxRetries: 3,
    encrypted: true
)

// 在视图模型中更新配置
viewModel.updateConfiguration(config)
```

## 扩展配网方式

要添加新的配网方式，只需：

1. 在`ProvisioningMethodType`枚举中添加新的配网方式
2. 创建新的配网服务类，实现`ProvisioningServiceProtocol`协议
3. 在`DeviceProvisioningModule`中注册新的服务
4. 在视图层添加相应的UI组件

## 测试

模块包含了完整的单元测试，可以通过Xcode的测试功能运行：

```bash
# 运行单元测试
xcodebuild test -workspace iOSPluginDemo.xcworkspace -scheme iOSPluginDemo -destination 'platform=iOS Simulator,name=iPhone 14'
```

## 注意事项

1. 蓝牙配网需要在真机上测试，模拟器不支持蓝牙功能
2. WiFi配网在iOS中有一些限制，应用无法直接连接WiFi网络
3. 二维码配网需要集成二维码扫描库（如AVFoundation）
4. 所有配网操作都应在后台线程执行，避免阻塞UI线程