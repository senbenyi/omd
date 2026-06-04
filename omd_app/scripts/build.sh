#!/bin/bash

# Flutter 构建脚本
# 使用方法: ./scripts/build.sh [dev|test|pro] [apk|appbundle|ios|web]

# 检查参数
if [ $# -lt 2 ]; then
    echo "使用方法: $0 [环境] [平台]"
    echo "环境: dev, test, pro"
    echo "平台: apk, appbundle, ios, web"
    echo ""
    echo "示例:"
    echo "  $0 dev apk      # 构建开发环境APK"
    echo "  $0 pro appbundle # 构建生产环境AAB"
    echo "  $0 test ios     # 构建测试环境iOS"
    exit 1
fi

ENV=$1
PLATFORM=$2

# 验证环境参数
if [[ ! "$ENV" =~ ^(dev|test|pro)$ ]]; then
    echo "❌ 错误: 环境必须是 dev, test 或 pro"
    exit 1
fi

# 验证平台参数
if [[ ! "$PLATFORM" =~ ^(apk|appbundle|ios|web)$ ]]; then
    echo "❌ 错误: 平台必须是 apk, appbundle, ios 或 web"
    exit 1
fi

echo "🚀 开始构建..."
echo "📱 平台: $PLATFORM"
echo "🌍 环境: $ENV"

# 设置构建参数
BUILD_ARGS="--dart-define=FLUTTER_ENV=$ENV"

# 根据环境设置不同的构建配置
case $ENV in
    "dev")
        BUILD_ARGS="$BUILD_ARGS --debug --no-tree-shake-icons"
        echo "🔧 开发环境: 启用调试模式"
        ;;
    "test")
        BUILD_ARGS="$BUILD_ARGS --profile --no-tree-shake-icons"
        echo "🧪 测试环境: 启用性能分析模式"
        ;;
    "pro")
        BUILD_ARGS="$BUILD_ARGS --release --no-tree-shake-icons"
        echo "🏭 生产环境: 启用发布模式"
        ;;
esac

# 执行构建命令
case $PLATFORM in
    "apk")
        echo "📦 构建 Android APK..."
        flutter build apk $BUILD_ARGS
        ;;
    "appbundle")
        echo "📦 构建 Android App Bundle..."
        flutter build appbundle $BUILD_ARGS
        ;;
    "ios")
        echo "📦 构建 iOS..."
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        # CI 或本机连打时避免 login 钥匙串上锁导致签名失败：export KEYCHAIN_PASSWORD 后生效
        "$SCRIPT_DIR/unlock_login_keychain_for_codesign.sh"
        flutter build ios $BUILD_ARGS
        ;;
    "web")
        echo "📦 构建 Web..."
        flutter build web $BUILD_ARGS
        ;;
esac

if [ $? -eq 0 ]; then
    echo "✅ 构建完成!"
    
    # 显示构建产物位置
    case $PLATFORM in
        "apk")
            echo "📱 APK 位置: build/app/outputs/flutter-apk/app-$ENV-release.apk"
            ;;
        "appbundle")
            echo "📱 AAB 位置: build/app/outputs/bundle/release/app-$ENV-release.aab"
            ;;
        "ios")
            echo "📱 iOS 构建完成，请使用 Xcode 进行签名和打包"
            ;;
        "web")
            echo "🌐 Web 构建完成，文件位置: build/web/"
            ;;
    esac
else
    echo "❌ 构建失败!"
    exit 1
fi 