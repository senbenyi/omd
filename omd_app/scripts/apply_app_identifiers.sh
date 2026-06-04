#!/bin/bash
# 根据配置动态修改：
# - iOS: bundle identifier、Info.plist com.xinstall.APP_KEY、CFBundleDisplayName
# - Android: applicationId、build.gradle.kts xinstallAppKey、app_name（桌面显示名）
# iOS 和 Android 的 Xinstall 均使用 installKey
# 用法: ./apply_app_identifiers.sh <IOS_BUNDLE_ID> <ANDROID_APP_ID> [XINSTALL_KEY] [XINSTALL_KEY] [APP_NAME] [PROJECT_ROOT]
#
# 例如: ./apply_app_identifiers.sh com.mg91ty.app com.mg91ty.app wz8dv4hw wz8dv4hw 天涯
# 打包时从 config 的 appName 传入第 5 个参数即可覆盖 iOS 与 Android 的 display name
# 如果是 Melos 多 app 结构，可额外传入第 6 个参数指定项目根目录（例如：apps/adultdy）

set -e

IOS_BUNDLE_ID="$1"
ANDROID_APP_ID="$2"
IOS_XINSTALL_KEY="$3"
ANDROID_XINSTALL_KEY="$4"
APP_DISPLAY_NAME="$5"
PROJECT_ROOT_OVERRIDE="$6"

if [ -z "$IOS_BUNDLE_ID" ] || [ -z "$ANDROID_APP_ID" ]; then
  echo "用法: $0 <IOS_BUNDLE_ID> <ANDROID_APP_ID> [XINSTALL_KEY] [XINSTALL_KEY] [APP_NAME] [PROJECT_ROOT]"
  exit 1
fi

if [[ "$IOS_BUNDLE_ID" == *"-"* ]]; then
  echo "❌ iOS 包名不合法（包含 - ）: $IOS_BUNDLE_ID"
  exit 1
fi
if [[ "$ANDROID_APP_ID" == *"-"* ]]; then
  echo "❌ Android 包名不合法（包含 - ）: $ANDROID_APP_ID"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -n "$PROJECT_ROOT_OVERRIDE" ]; then
  PROJECT_ROOT="$(cd "$PROJECT_ROOT_OVERRIDE" && pwd)"
else
  PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
fi
cd "$PROJECT_ROOT"

echo "📝 项目目录: $PROJECT_ROOT"
echo "📝 应用配置: iOS=$IOS_BUNDLE_ID, Android=$ANDROID_APP_ID, Xinstall=$IOS_XINSTALL_KEY, AppName=${APP_DISPLAY_NAME:-（未设置）}"

# ========== Android ==========
if [ -f "android/app/build.gradle.kts" ]; then
  sed -i.bak "s/applicationId = \"[^\"]*\"/applicationId = \"$ANDROID_APP_ID\"/" android/app/build.gradle.kts
  rm -f android/app/build.gradle.kts.bak
fi

if [ -n "$ANDROID_XINSTALL_KEY" ] && [ -f "android/app/build.gradle.kts" ]; then
  sed -i.bak "s/val xinstallAppKey = \"[^\"]*\"/val xinstallAppKey = \"$ANDROID_XINSTALL_KEY\"/" android/app/build.gradle.kts
  rm -f android/app/build.gradle.kts.bak
fi

# Android display name（app_name）
if [ -n "$APP_DISPLAY_NAME" ] && [ -f "android/app/src/main/res/values/styles.xml" ]; then
  export APP_DISPLAY_NAME
  APP_DISPLAY_NAME="$APP_DISPLAY_NAME" python3 -c "
import os, re, xml.sax.saxutils
name = os.environ.get('APP_DISPLAY_NAME', '')
path = 'android/app/src/main/res/values/styles.xml'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()
escaped = xml.sax.saxutils.escape(name)
content = re.sub(r'(<string name=\"app_name\">)[^<]*(</string>)', r'\g<1>' + escaped + r'\g<2>', content)
with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
"
  echo "Android app_name 已设为: $APP_DISPLAY_NAME"
fi

echo "--- Android 修改后 ---"
grep -E "applicationId|namespace|xinstallAppKey" android/app/build.gradle.kts 2>/dev/null | head -5 || true

# ========== iOS ==========
PBXPROJ="ios/Runner.xcodeproj/project.pbxproj"
INFOPLIST="ios/Runner/Info.plist"
if [ -f "$PBXPROJ" ]; then
  # 更稳：替换所有非 RunnerTests 的 PRODUCT_BUNDLE_IDENTIFIER
  PBXPROJ_PATH="$PBXPROJ" IOS_BUNDLE="$IOS_BUNDLE_ID" python3 -c "
import os, re
path = os.environ['PBXPROJ_PATH']
bundle = os.environ['IOS_BUNDLE']
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()
def repl(m):
    line = m.group(0)
    return line if 'RunnerTests' in line else f'PRODUCT_BUNDLE_IDENTIFIER = {bundle};'
new_content, n = re.subn(r'PRODUCT_BUNDLE_IDENTIFIER\\s*=\\s*[^;]+;', repl, content)
with open(path, 'w', encoding='utf-8') as f:
    f.write(new_content)
print(f'iOS PBXPROJ bundle ids updated: {n}')
"
fi

if [ -n "$IOS_XINSTALL_KEY" ] || [ -n "$APP_DISPLAY_NAME" ]; then
  if [ -f "$INFOPLIST" ]; then
    export APP_DISPLAY_NAME APPL_IOS_XINSTALL_KEY
    APP_DISPLAY_NAME="$APP_DISPLAY_NAME" APPL_IOS_XINSTALL_KEY="$IOS_XINSTALL_KEY" python3 -c "
import os, plistlib
plist_path = \"$INFOPLIST\"
with open(plist_path, 'rb') as f:
    plist = plistlib.load(f)
xinstall = os.environ.get('APPL_IOS_XINSTALL_KEY', '')
if xinstall:
    plist['com.xinstall.APP_KEY'] = xinstall
name = os.environ.get('APP_DISPLAY_NAME', '')
if name:
    plist['CFBundleDisplayName'] = name
with open(plist_path, 'wb') as f:
    plistlib.dump(plist, f, fmt=plistlib.FMT_XML, sort_keys=False)
"
    [ -n "$APP_DISPLAY_NAME" ] && echo "iOS CFBundleDisplayName 已设为: $APP_DISPLAY_NAME"
  fi
fi

echo "--- iOS 修改后 ---"
grep "PRODUCT_BUNDLE_IDENTIFIER = " "$PBXPROJ" 2>/dev/null | grep -v RunnerTests | head -3 || true
if [ -f "$INFOPLIST" ]; then
  echo "Info.plist com.xinstall.APP_KEY: $(python3 -c "import plistlib; print(plistlib.load(open('$INFOPLIST','rb')).get('com.xinstall.APP_KEY',''))")"
fi

echo "✅ 配置已应用"
