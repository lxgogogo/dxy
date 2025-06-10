#!/bin/bash

# 1. 添加执行权限：chmod +x build_release.sh
# 2. 运行脚本：./build_release.sh

# 读取 pubspec.yaml 中的项目名称和版本号
name=$(grep '^name:' pubspec.yaml | sed 's/^name: //' | tr -d ' ')
version=$(grep '^version:' pubspec.yaml | sed 's/^version: //' | tr -d ' ')

# 处理版本号（将 + 替换为 - 用于命名）
version_clean=${version//+/-}           # 文件命名用
main_version=$(echo "$version" | cut -d "+" -f1)  # 用于目录分类

# 定义 APK 输出文件名
apk_v7a="${name}_${version_clean}_v7a.apk"
apk_v8a="${name}_${version_clean}_v8a.apk"

# 创建输出目录
release_package_directory="release-package"
target_directory="${release_package_directory}/${main_version}"
mkdir -p "$target_directory"

echo "🔧 使用 fvm 打包 APK（armeabi-v7a 和 arm64-v8a）..."
fvm flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64

# 移动输出的 APK 文件
mv build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk "$target_directory/$apk_v7a"
mv build/app/outputs/flutter-apk/app-arm64-v8a-release.apk "$target_directory/$apk_v8a"

echo "✅ APK 打包完成："
echo " - $target_directory/$apk_v7a"
echo " - $target_directory/$apk_v8a"

# 打开输出目录（macOS 可用）
open "$target_directory"

echo "✨ 打包完成，输出目录: $target_directory"
