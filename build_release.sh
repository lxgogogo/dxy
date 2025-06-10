#!/bin/bash

# 1. 添加执行权限：chmod +x build_release.sh
# 2. 运行脚本：./build_release.sh [环境]
# 环境参数：dev, test, prod1, prod2，默认为 test

# 设置默认环境为 test
ENV=${1:-test}

# 读取 pubspec.yaml 中的项目名称和版本号
name=$(grep '^name:' pubspec.yaml | sed 's/^name: //' | tr -d ' ')
version=$(grep '^version:' pubspec.yaml | sed 's/^version: //' | tr -d ' ')

# 处理版本号（将 + 替换为 - 用于命名）
version_clean=${version//+/-}           # 文件命名用
main_version=$(echo "$version" | cut -d "+" -f1)  # 用于目录分类

# 定义输出文件名
apk="${name}_${version_clean}_${ENV}.apk"
aab="${name}_${version_clean}_${ENV}.aab"
ipa="${name}_${version_clean}_${ENV}.ipa"

# 创建输出目录
release_package_directory="release-package"
target_directory="${release_package_directory}/${main_version}"
mkdir -p "$target_directory"

# 修改 build.gradle 文件，添加 ABI 过滤
echo "🔧 配置 Android ABI 过滤..."
sed -i '' 's/ndk {/ndk {\n            abiFilters "armeabi-v7a", "arm64-v8a"/' android/app/build.gradle

# 打包 Android APK
echo "🔧 开始打包 Android APK (环境: $ENV)..."
fvm flutter build apk --release --dart-define=ENV=$ENV

# 移动 APK 文件
mv build/app/outputs/flutter-apk/app-release.apk "$target_directory/$apk"

echo "✅ Android APK 打包完成："
echo " - $target_directory/$apk"

# 打包 Android AAB
echo "🔧 开始打包 Android AAB (环境: $ENV)..."
fvm flutter build appbundle --release --dart-define=ENV=$ENV

# 移动 AAB 文件
mv build/app/outputs/bundle/release/app-release.aab "$target_directory/$aab"

echo "✅ Android AAB 打包完成："
echo " - $target_directory/$aab"

# 打包 iOS IPA
echo "🔧 开始打包 iOS IPA (环境: $ENV)..."
fvm flutter build ipa --release --dart-define=ENV=$ENV

# 移动 IPA 文件
mv build/ios/ipa/*.ipa "$target_directory/$ipa"

echo "✅ iOS IPA 打包完成："
echo " - $target_directory/$ipa"

# 打开输出目录（macOS 可用）
open "$target_directory"

echo "✨ 所有打包完成，输出目录: $target_directory"