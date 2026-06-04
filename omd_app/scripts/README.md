# Flutter 构建脚本使用指南

## 概述

本项目提供了便捷的构建脚本来简化不同环境的 Flutter 应用构建过程。

## 脚本文件

- `build.sh` - Linux/macOS 构建脚本
- `build.bat` - Windows 构建脚本

## 使用方法

### 基本语法

```bash
# Linux/macOS
./scripts/build.sh [环境] [平台]

# Windows
scripts\build.bat [环境] [平台]
```

### 参数说明

| 参数 | 可选值 | 说明 |
|------|--------|------|
| 环境 | `dev`, `test`, `pro` | 构建环境 |
| 平台 | `apk`, `appbundle`, `ios`, `web` | 目标平台 |

### 使用示例

#### 开发环境构建

```bash
# 构建开发环境 APK
./scripts/build.sh dev apk

# 构建开发环境 App Bundle
./scripts/build.sh dev appbundle

# 构建开发环境 iOS
./scripts/build.sh dev ios

# 构建开发环境 Web
./scripts/build.sh dev web
```

#### 测试环境构建

```bash
# 构建测试环境 APK
./scripts/build.sh test apk

# 构建测试环境 App Bundle
./scripts/build.sh test appbundle
```

#### 生产环境构建

```bash
# 构建生产环境 APK
./scripts/build.sh pro apk

# 构建生产环境 App Bundle
./scripts/build.sh pro appbundle
```

## 环境配置说明

### 开发环境 (dev)
- 启用调试模式 (`--debug`)
- 启用调试日志
- 较短的超时时间
- 用于开发和测试

### 测试环境 (test)
- 启用性能分析模式 (`--profile`)
- 启用调试日志
- 中等超时时间
- 用于集成测试

### 生产环境 (pro)
- 启用发布模式 (`--release`)
- 关闭调试日志
- 标准超时时间
- 用于生产发布

## 构建产物位置

### Android APK
```
build/app/outputs/flutter-apk/app-[环境]-release.apk
```

### Android App Bundle
```
build/app/outputs/bundle/release/app-[环境]-release.aab
```

### iOS
构建完成后需要使用 Xcode 进行签名和打包

### Web
```
build/web/
```

## 手动构建命令

如果不想使用脚本，也可以直接使用 Flutter 命令：

### 开发环境
```bash
flutter build apk --dart-define=FLUTTER_ENV=dev --debug
flutter build appbundle --dart-define=FLUTTER_ENV=dev --debug
flutter build ios --dart-define=FLUTTER_ENV=dev --debug
flutter build web --dart-define=FLUTTER_ENV=dev --debug
```

### 测试环境
```bash
flutter build apk --dart-define=FLUTTER_ENV=test --profile
flutter build appbundle --dart-define=FLUTTER_ENV=test --profile
flutter build ios --dart-define=FLUTTER_ENV=test --profile
flutter build web --dart-define=FLUTTER_ENV=test --profile
```

### 生产环境
```bash
flutter build apk --dart-define=FLUTTER_ENV=pro --release
flutter build appbundle --dart-define=FLUTTER_ENV=pro --release
flutter build ios --dart-define=FLUTTER_ENV=pro --release
flutter build web --dart-define=FLUTTER_ENV=pro --release
```

## 注意事项

1. **环境变量**: 确保在构建时正确设置 `FLUTTER_ENV` 环境变量
2. **依赖检查**: 构建前确保所有依赖都已安装 (`flutter pub get`)
3. **权限设置**: 确保脚本有执行权限 (`chmod +x scripts/build.sh`)
4. **平台要求**: iOS 构建需要 macOS 和 Xcode
5. **签名配置**: 生产环境构建需要正确的签名配置

## 故障排除

### 常见问题

1. **脚本权限错误**
   ```bash
   chmod +x scripts/build.sh
   ```

2. **Flutter 命令未找到**
   ```bash
   flutter doctor
   ```

3. **构建失败**
   - 检查依赖: `flutter pub get`
   - 清理缓存: `flutter clean`
   - 检查环境配置

4. **iOS 构建问题**
   - 确保 Xcode 已安装
   - 检查签名配置
   - 运行 `flutter doctor` 检查 iOS 工具链

## 扩展脚本

你可以根据需要扩展这些脚本：

- 添加自动版本号管理
- 集成 CI/CD 流程
- 添加构建后处理步骤
- 集成代码签名自动化 