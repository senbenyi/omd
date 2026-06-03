#!/usr/bin/env bash
set -euo pipefail
export PATH="${HOME}/.dotnet:${PATH}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/src/OmdServer"
exec dotnet run --urls "http://0.0.0.0:5080"
