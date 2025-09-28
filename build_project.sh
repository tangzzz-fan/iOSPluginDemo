#!/bin/bash
# iOS项目构建脚本

echo "开始构建iOS项目..."

# 进入iOS目录
cd /Users/apple/Developments/FlutterPluginDemo/ios_module

# 检查工作区文件是否存在
if [ ! -d "SwiftFlutter.xcworkspace" ]; then
  echo "错误: SwiftFlutter.xcworkspace 目录不存在"
  exit 1
fi

echo "✓ 工作区文件存在"

# 使用可用的模拟器设备进行构建，忽略警告
echo "正在执行构建命令..."
xcodebuild -workspace SwiftFlutter.xcworkspace -scheme SwiftFlutter -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' clean build CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO GCC_WARN_INHIBIT_ALL_WARNINGS=YES

# 检查构建结果
if [ $? -eq 0 ]; then
  echo "✓ 项目构建成功!"
else
  echo "✗ 项目构建失败!"
  exit 1
fi