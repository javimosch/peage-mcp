#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
MACHIN="${MACHIN:-machin}"
"$MACHIN" encode src/config.src src/tools.src src/mcp.src src/main.src > app.mfl
"$MACHIN" build app.mfl -o peage-mcp
echo "built ./peage-mcp"
