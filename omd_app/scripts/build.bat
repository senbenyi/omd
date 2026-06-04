@echo off
setlocal enabledelayedexpansion

REM Flutter 构建脚本 (Windows)
REM 使用方法: build.bat [dev|test|pro] [apk|appbundle|ios|web]

REM 检查参数
if "%~2"=="" (
    echo 使用方法: %0 [环境] [平台]
    echo 环境: dev, test, pro
    echo 平台: apk, appbundle, ios, web
    echo.
    echo 示例:
    echo   %0 dev apk      # 构建开发环境APK
    echo   %0 pro appbundle # 构建生产环境AAB
    echo   %0 test ios     # 构建测试环境iOS
    exit /b 1
)

set ENV=%~1
set PLATFORM=%~2

REM 验证环境参数
if not "%ENV%"=="dev" if not "%ENV%"=="test" if not "%ENV%"=="pro" (
    echo ❌ 错误: 环境必须是 dev, test 或 pro
    exit /b 1
)

REM 验证平台参数
if not "%PLATFORM%"=="apk" if not "%PLATFORM%"=="appbundle" if not "%PLATFORM%"=="ios" if not "%PLATFORM%"=="web" (
    echo ❌ 错误: 平台必须是 apk, appbundle, ios 或 web
    exit /b 1
)

echo 🚀 开始构建...
echo 📱 平台: %PLATFORM%
echo 🌍 环境: %ENV%

REM 设置构建参数
set BUILD_ARGS=--dart-define=FLUTTER_ENV=%ENV%

REM 根据环境设置不同的构建配置
if "%ENV%"=="dev" (
    set BUILD_ARGS=%BUILD_ARGS% --debug
    echo 🔧 开发环境: 启用调试模式
) else if "%ENV%"=="test" (
    set BUILD_ARGS=%BUILD_ARGS% --profile
    echo 🧪 测试环境: 启用性能分析模式
) else if "%ENV%"=="pro" (
    set BUILD_ARGS=%BUILD_ARGS% --release
    echo 🏭 生产环境: 启用发布模式
)

REM 执行构建命令
if "%PLATFORM%"=="apk" (
    echo 📦 构建 Android APK...
    flutter build apk %BUILD_ARGS%
) else if "%PLATFORM%"=="appbundle" (
    echo 📦 构建 Android App Bundle...
    flutter build appbundle %BUILD_ARGS%
) else if "%PLATFORM%"=="ios" (
    echo 📦 构建 iOS...
    flutter build ios %BUILD_ARGS%
) else if "%PLATFORM%"=="web" (
    echo 📦 构建 Web...
    flutter build web %BUILD_ARGS%
)

if %ERRORLEVEL%==0 (
    echo ✅ 构建完成!
    
    REM 显示构建产物位置
    if "%PLATFORM%"=="apk" (
        echo 📱 APK 位置: build\app\outputs\flutter-apk\app-%ENV%-release.apk
    ) else if "%PLATFORM%"=="appbundle" (
        echo 📱 AAB 位置: build\app\outputs\bundle\release\app-%ENV%-release.aab
    ) else if "%PLATFORM%"=="ios" (
        echo 📱 iOS 构建完成，请使用 Xcode 进行签名和打包
    ) else if "%PLATFORM%"=="web" (
        echo 🌐 Web 构建完成，文件位置: build\web\
    )
) else (
    echo ❌ 构建失败!
    exit /b 1
) 