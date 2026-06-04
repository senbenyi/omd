#!/usr/bin/env bash
# 在 macOS 上解锁 login.keychain，便于 codesign / xcodebuild exportArchive 访问分发证书私钥。
# 典型场景：Jenkins 同一 Job 连续打多个 iOS 包，钥匙串超时上锁后整批 exportArchive 失败。
#
# 用法：在构建前执行（仓库根或任意目录均可）
#   export KEYCHAIN_PASSWORD='你的登录钥匙串密码'
#   ./scripts/unlock_login_keychain_for_codesign.sh
#
# 环境变量：
#   KEYCHAIN_PASSWORD  必填才会解锁；未设置则跳过（退出 0）
#   KEYCHAIN_PATH        可选，默认 $HOME/Library/Keychains/login.keychain-db
#   VERBOSE              非空时打印 keychain 列表与 codesigning 身份（前 50 行）

set -u

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "unlock_login_keychain_for_codesign: not macOS, skip"
  exit 0
fi

LOGINKC="${KEYCHAIN_PATH:-$HOME/Library/Keychains/login.keychain-db}"

if [[ -n "${VERBOSE:-}" ]]; then
  echo "---- iOS signing env (user=$(whoami)) ----"
  security list-keychains -d user 2>/dev/null || true
  security find-identity -v -p codesigning 2>/dev/null | head -50 || true
fi

if [[ -z "${KEYCHAIN_PASSWORD:-}" ]]; then
  echo "unlock_login_keychain_for_codesign: KEYCHAIN_PASSWORD not set, skip"
  exit 0
fi

if [[ ! -f "$LOGINKC" ]]; then
  echo "unlock_login_keychain_for_codesign: keychain not found: $LOGINKC"
  exit 1
fi

echo "unlock_login_keychain_for_codesign: unlocking for codesign"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$LOGINKC" || {
  echo "unlock_login_keychain_for_codesign: unlock failed (wrong KEYCHAIN_PASSWORD or path?)"
  exit 1
}
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" "$LOGINKC" 2>/dev/null || true
