#!/usr/bin/env bash
# VS Code / Cursor 构建任务用：不依赖全局 PATH 中的 dotnet
set -euo pipefail
export PATH="${HOME}/.dotnet:${PATH}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec dotnet build "${ROOT}/src/OmdServer/OmdServer.csproj" \
  /property:GenerateFullPaths=true \
  /consoleloggerparameters:NoSummary\;ForceNoAlign
