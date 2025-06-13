#!/bin/bash

# 定义环境选项
environments=("dev" "test" "prod1" "prod2")

# 显示环境选项
echo "🌍 请选择环境："
for i in "${!environments[@]}"; do
    echo "$((i+1))) ${environments[$i]}"
done

# 读取用户选择
read -p "请输入选项编号 (默认: 2): " env_choice

# 如果用户没有输入，使用默认值
if [ -z "$env_choice" ]; then
    env_choice=2
fi

# 获取选择的环境
ENV=${environments[$((env_choice-1))]}
echo "ℹ️ 已选择环境: $ENV"

# 定义平台选项
platforms=("Android APK" "Android AAB" "iOS IPA")
selected_platforms=()

# 显示平台选项
echo "📱 请选择打包平台（可多选，输入数字，多个数字用空格分隔）："
for i in "${!platforms[@]}"; do
    echo "$((i+1))) ${platforms[$i]}"
done

# 读取用户选择
read -p "请输入选项编号 (默认: 1 3): " platform_choices

# 如果用户没有输入，使用默认值
if [ -z "$platform_choices" ]; then
    platform_choices="1 3"
fi

# 处理用户选择的平台
for choice in $platform_choices; do
    if [[ $choice =~ ^[1-3]$ ]]; then
        selected_platforms+=("${platforms[$((choice-1))]}")
    fi
done

# 如果用户没有选择任何平台，使用默认值
if [ ${#selected_platforms[@]} -eq 0 ]; then
    selected_platforms=("Android APK" "iOS IPA")
fi

echo "ℹ️ 已选择平台: ${selected_platforms[*]}"

# 读取 pubspec.yaml 中的项目名称和版本号
name=$(grep '^name:' pubspec.yaml | sed 's/^name: //' | tr -d ' ')
version=$(grep '^version:' pubspec.yaml | sed 's/^version: //' | tr -d ' ')

# 更新版本号（将版本号加1）
IFS='+' read -r main_version build_number <<< "$version"
new_build_number=$((build_number + 1))
new_version="${main_version}+${new_build_number}"

# 询问是否提交版本号更新
echo "📝 是否提交版本号更新？($version -> $new_version)"
echo "1) 是 (默认)"
echo "2) 否"
read -p "请选择 (1/2): " commit_choice

# 如果用户没有输入，使用默认值（提交）
if [ -z "$commit_choice" ]; then
    commit_choice=1
fi

if [ "$commit_choice" = "1" ]; then
    # 更新 pubspec.yaml 中的版本号
    echo "🔧 更新版本号: $version -> $new_version"
    sed -i '' "s/^version: $version/version: $new_version/" pubspec.yaml

    # 提交版本号更新
    echo "🔧 提交版本号更新..."
    git add pubspec.yaml
    git commit -m "chore: 自动更新版本号：$new_version"
else
    echo "ℹ️ 跳过版本号更新"
    new_version=$version
fi

# 处理版本号（将 + 替换为 - 用于命名）
version_clean=${new_version//+/-}
main_version=$(echo "$new_version" | cut -d "+" -f1)

# 创建输出目录
release_package_directory="release-package"
target_directory="${release_package_directory}/${main_version}"
mkdir -p "$target_directory"

# 打包函数
build_apk() {
    echo "🔧 开始打包 Android APK (环境: $ENV)..."
    fvm flutter build apk --release --dart-define=ENV=$ENV
    mv build/app/outputs/flutter-apk/app-release.apk "$target_directory/${name}_${version_clean}_${ENV}.apk"
    echo "✅ Android APK 打包完成"
}

build_aab() {
    echo "🔧 开始打包 Android AAB (环境: $ENV)..."
    fvm flutter build appbundle --release --dart-define=ENV=$ENV
    mv build/app/outputs/bundle/release/app-release.aab "$target_directory/${name}_${version_clean}_${ENV}.aab"
    echo "✅ Android AAB 打包完成"
}

build_ipa() {
    echo "🔧 开始打包 iOS IPA (环境: $ENV)..."
    fvm flutter build ipa --release --dart-define=ENV=$ENV
    mv build/ios/ipa/*.ipa "$target_directory/${name}_${version_clean}_${ENV}.ipa"
    echo "✅ iOS IPA 打包完成"
}

# 根据选择执行打包
for platform in "${selected_platforms[@]}"; do
    case "$platform" in
        "Android APK")
            build_apk
            ;;
        "Android AAB")
            build_aab
            ;;
        "iOS IPA")
            build_ipa
            ;;
    esac
done

# 打开输出目录（macOS 可用）
open "$target_directory"

echo "✨ 所有打包完成，输出目录: $target_directory"