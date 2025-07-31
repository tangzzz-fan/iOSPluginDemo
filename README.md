# iOSPluginDemo

一个基于 MVVMC + Swinject + Combine 架构的 iOS 应用示例项目。

## 项目概述

本项目展示了如何使用现代 iOS 开发技术栈构建一个模块化、可扩展的应用程序：

- **MVVMC**: Model-View-ViewModel-Coordinator 架构模式
- **Swinject**: 依赖注入框架
- **Combine**: 响应式编程框架
- **Anchorage**: 自动布局框架
- **SwiftyBeaver**: 日志框架

## 架构特点

### 1. 协议导向设计
- 避免继承，使用协议和扩展
- 每个组件都有清晰的接口定义
- 易于测试和扩展

### 2. 模块化架构
- 每个功能模块独立，包含完整的 MVVMC 组件
- 模块间通过依赖注入解耦
- 支持动态模块注册和加载

### 3. 协调器模式
- 统一的导航管理
- 生命周期管理
- 模块间通信

## 模块结构

项目采用模块化设计，每个功能模块都包含完整的 MVVMC 组件：

- **Core**: 核心协议和基础组件
- **Auth**: 用户认证模块（登录、注册、忘记密码）
- **Home**: 首页模块
- **Profile**: 个人资料模块  
- **Settings**: 设置模块

## 核心组件

### 1. 协议定义
- `Coordinator`: 协调器协议
- `ViewControllable`: 视图控制器协议
- `ViewModelable`: 视图模型协议
- `Module`: 模块协议

### 2. 依赖注入
- `DIContainerManager`: 依赖注入容器管理
- `CoordinatorFactory`: 协调器工厂
- `ModuleFactory`: 模块工厂

### 3. 导航管理
- `MainCoordinator`: 主协调器
- `NavigationBarConfigurable`: 导航栏配置协议

## 快速开始

### 1. 安装依赖
```bash
pod install
```

### 2. 打开项目
```bash
open iOSPluginDemo.xcworkspace
```

### 3. 运行应用
- 选择模拟器或真机
- 点击运行按钮

### 4. 测试认证
使用以下测试账户登录：
- **邮箱**: `test@example.com`
- **密码**: `password`

## 项目结构

```
iOSPluginDemo/
├── Core/                    # 核心协议和基础组件
│   ├── Coordinator.swift
│   ├── ViewControllable.swift
│   ├── ViewModelable.swift
│   ├── ModuleProtocols.swift
│   ├── DIContainer.swift
│   ├── ArchitectureValidator.swift
│   └── NavigationBarConfigurable.swift
├── Auth/                    # 认证模块
│   ├── AuthModule.swift
│   ├── AuthCoordinator.swift
│   ├── AuthViewModel.swift
│   ├── AuthViewController.swift
│   ├── ForgotPasswordViewController.swift
│   ├── RegistrationViewController.swift
│   └── README.md
├── Home/                    # 首页模块
│   ├── HomeModule.swift
│   ├── HomeCoordinator.swift
│   ├── HomeViewModel.swift
│   ├── HomeViewController.swift
│   └── HomeDetailViewController.swift
├── Profile/                 # 个人资料模块
│   ├── ProfileModule.swift
│   ├── ProfileCoordinator.swift
│   └── ProfileViewController.swift
├── Settings/                # 设置模块
│   ├── SettingsModule.swift
│   ├── SettingsCoordinator.swift
│   └── SettingsViewController.swift
├── Main/                    # 主协调器
│   └── MainCoordinator.swift
└── iOSPluginDemo/           # 应用入口
    ├── AppDelegate.swift
    ├── SceneDelegate.swift
    └── Info.plist
```

## 开发指南

### 1. 添加新模块
1. 创建模块目录（如 `NewFeature/`）
2. 实现 `Module` 协议
3. 创建 `Coordinator`、`ViewModel`、`ViewController`
4. 在 `DIContainer` 中注册依赖
5. 在 `MainCoordinator` 中集成

### 2. 自定义 UI
- 使用 `NavigationBarConfigurable` 协议统一导航栏样式
- 使用 Anchorage 进行自动布局
- 遵循协议导向设计原则

### 3. 添加新功能
- 在相应的 ViewModel 中添加业务逻辑
- 使用 Combine 进行数据绑定
- 通过 Swinject 注入依赖

## 技术栈

- **iOS**: 15.0+
- **Swift**: 5.0+
- **Xcode**: 14.0+
- **CocoaPods**: 1.12.0+

## 依赖库

- **Swinject**: 依赖注入
- **Combine**: 响应式编程
- **Anchorage**: 自动布局
- **SwiftyBeaver**: 日志记录
- **Moya**: 网络请求（预留）

## 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 许可证

MIT License

## 联系方式

如有问题或建议，请提交 Issue 或 Pull Request。