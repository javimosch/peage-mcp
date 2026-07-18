#!/usr/bin/env bash
# Package peage-mcp into a distributable .mcpb bundle (a zip: manifest.json + the binary).
# NOTE: the bundled binary is linux/x86_64 (compatibility.platforms=["linux"]). Build on the
# target platform to produce mac/windows bundles once machin cross-compile is wired up.
set -euo pipefail
cd "$(dirname "$0")"
./build.sh
rm -rf .pkg peage-mcp.mcpb
mkdir -p .pkg
cp peage-mcp manifest.json .pkg/
( cd .pkg && zip -q -r ../peage-mcp.mcpb manifest.json peage-mcp )
rm -rf .pkg
echo "built ./peage-mcp.mcpb ($(du -h peage-mcp.mcpb | cut -f1))"
