# Demo模块功能说明

## 概述

本项目新增了一个"Demo"标签页，用于展示各种功能演示，采用完整的MVVM-C + Swinject + Combine架构实现。

## 功能特性

### 1. Demo列表页面
- **模块**: `DemoListViewController` + `DemoListViewModel`
- **功能**: 
  - 分类展示各种演示功能
  - 支持搜索和筛选
  - 响应式UI设计
  - 下拉刷新

### 2. 长截图功能演示
- **模块**: `LongScreenshotDemoViewController` + `LongScreenshotDemoViewModel`
- **核心服务**: `ScreenshotGenerator` (实现 `ScreenshotGenerating` 协议)
- **功能**: 
  - 生成完整的长截图
  - 支持分享到各个平台
  - 异步处理，不阻塞UI
  - 完整的错误处理

## 架构设计

### 依赖注入配置
所有组件都通过Swinject容器进行依赖注入：

```swift
// DemoModule注册
container.register(ScreenshotGenerating.self) { _ in
    ScreenshotGenerator()
}.inObjectScope(.container)

container.register(DemoListViewModel.self) { _ in
    return DemoListViewModel()
}.inObjectScope(.transient)
```

### 导航协调
- `DemoCoordinator` 负责Demo模块内的所有导航逻辑
- `MainCoordinator` 管理Tab之间的切换
- 实现了 `DemoCoordinatorActions` 协议处理具体的导航需求

### 响应式编程
使用Combine框架实现：
- ViewModel的Input/Output模式
- 异步操作的响应式处理
- UI状态的响应式更新

## 技术实现亮点

### 1. 长截图算法
```swift
func generate(from scrollView: UIScrollView) -> AnyPublisher<UIImage, ScreenshotError> {
    // 1. 保存原始状态
    // 2. 调整视图框架到内容大小
    // 3. 渲染完整内容
    // 4. 恢复原始状态
    // 5. 异步返回结果
}
```

### 2. 模块化设计
- 每个Demo功能都是独立的模块
- 通过协议定义模块间的通信
- 便于扩展新的演示功能

### 3. UI组件
- `DemoItemTableViewCell`: 自定义表格单元格
- 支持分类标签和图标
- 流畅的选择动画

## 使用说明

1. **运行项目**: 启动后可在底部Tab栏看到"演示"选项
2. **浏览功能**: 点击进入可查看所有可用的演示功能
3. **长截图**: 
   - 选择"长截图分享"
   - 在演示页面点击右上角分享按钮
   - 系统会生成完整页面截图并提供分享选项

## 扩展指南

要添加新的演示功能：

1. **更新数据模型**: 在 `DemoDataProvider` 中添加新的 `DemoItem`
2. **实现功能**: 创建对应的ViewController和ViewModel
3. **注册依赖**: 在DI容器中注册新组件
4. **更新导航**: 在 `DemoCoordinator` 中添加导航逻辑

## 架构优势

- ✅ **可测试**: 所有组件都可以独立测试
- ✅ **可维护**: 清晰的模块分离和职责划分
- ✅ **可扩展**: 易于添加新的演示功能
- ✅ **响应式**: 流畅的用户体验
- ✅ **现代化**: 使用最新的iOS开发最佳实践
