# Auth 模块

## 概述

Auth 模块是 iOSPluginDemo 项目的认证模块，负责处理用户登录、注册、忘记密码等功能。该模块完全符合项目的 MVVMC 架构设计。

## 架构组件

### 1. AuthModule
- **位置**: `AuthModule.swift`
- **职责**: 模块的依赖注册和初始化
- **功能**: 
  - 注册 AuthService、AuthViewModel、AuthViewController 等依赖
  - 管理模块的生命周期

### 2. AuthCoordinator
- **位置**: `AuthCoordinator.swift`
- **职责**: 处理认证相关的导航逻辑
- **功能**:
  - 管理登录、注册、忘记密码页面的导航
  - 处理认证完成后的主应用切换
  - 包含 ForgotPasswordCoordinator 和 RegistrationCoordinator

### 3. AuthViewModel
- **位置**: `AuthViewModel.swift`
- **职责**: 处理认证业务逻辑和状态管理
- **功能**:
  - 用户登录验证
  - 输入验证和状态管理
  - 错误处理和日志记录
  - 认证状态检查

### 4. AuthViewController
- **位置**: `AuthViewController.swift`
- **职责**: 登录界面的 UI 展示和用户交互
- **功能**:
  - 邮箱和密码输入
  - 登录按钮状态管理
  - 加载状态显示
  - 错误信息展示

## 数据模型

### User
```swift
struct User: Codable {
    let id: String
    let email: String
    let name: String
    let avatarURL: String?
    let createdAt: Date
}
```

### AuthError
```swift
enum AuthError: LocalizedError {
    case invalidCredentials
    case notAuthenticated
    case networkError
    case serverError
}
```

## 服务层

### AuthServiceProtocol
定义了认证相关的服务接口：
- `login(email:password:)` - 用户登录
- `logout()` - 用户登出
- `checkAuthStatus()` - 检查认证状态
- `forgotPassword(email:)` - 忘记密码
- `register(email:password:name:)` - 用户注册

### AuthService
实现了 AuthServiceProtocol，提供模拟的认证服务。

## 使用示例

### 1. 登录测试
使用以下测试账户：
- **邮箱**: `test@example.com`
- **密码**: `password`

### 2. 模块集成
Auth 模块已经集成到主应用中：
- 应用启动时会检查认证状态
- 未认证用户会看到登录界面
- 认证成功后自动切换到主应用

### 3. 导航流程
```
启动应用 → 检查认证状态 → 显示登录界面 → 登录成功 → 切换到主应用
                ↓
            忘记密码/注册 → 相应页面 → 返回登录界面
```

## 扩展功能

### 1. 添加新的认证方式
1. 在 `AuthServiceProtocol` 中添加新方法
2. 在 `AuthService` 中实现该方法
3. 在 `AuthViewModel` 中添加相应的业务逻辑
4. 在 `AuthViewController` 中添加 UI 元素

### 2. 自定义 UI 样式
- 修改 `AuthViewController` 中的 UI 组件
- 调整颜色、字体、布局等
- 添加动画效果

### 3. 集成真实 API
- 替换 `AuthService` 中的模拟实现
- 添加网络请求和错误处理
- 实现 token 管理和持久化

## 注意事项

1. **安全性**: 当前实现为演示版本，生产环境需要加强安全措施
2. **持久化**: 认证状态暂未持久化，重启应用需要重新登录
3. **网络处理**: 当前使用模拟数据，实际使用时需要添加网络层
4. **错误处理**: 已实现基本的错误处理，可根据需要扩展

## 依赖关系

- **Swinject**: 依赖注入
- **Combine**: 响应式编程
- **Anchorage**: 自动布局
- **SwiftyBeaver**: 日志记录 