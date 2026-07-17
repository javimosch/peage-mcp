#!/usr/bin/env bash
# JSON-RPC-over-stdio test: pipe a scripted MCP session into the binary and
# assert on every response line. Read-only against the live rail by default
# (status/receipt/solvency); no money moves. Set PEAGE_URL to test elsewhere.
set -euo pipefail
cd "$(dirname "$0")"

export PEAGE_MCP_CONFIG=$(mktemp -d)/mcp.json
fail() { echo "FAIL: $1"; exit 1; }
PASS=0
ok() { PASS=$((PASS+1)); echo "ok $PASS - $1"; }

OUT=$(printf '%s\n' \
  '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"test","version":"0"}}}' \
  '{"jsonrpc":"2.0","method":"notifications/initialized"}' \
  '{"jsonrpc":"2.0","id":2,"method":"ping"}' \
  '{"jsonrpc":"2.0","id":3,"method":"tools/list"}' \
  '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"peage_solvency","arguments":{}}}' \
  '{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"peage_status","arguments":{}}}' \
  '{"jsonrpc":"2.0","id":6,"method":"tools/call","params":{"name":"nope","arguments":{}}}' \
  '{"jsonrpc":"2.0","id":7,"method":"bogus/method"}' \
  | ./peage-mcp serve 2>/dev/null)

L() { echo "$OUT" | sed -n "${1}p"; }
J() { python3 -c "import json,sys; print(json.load(sys.stdin)$1)"; }

[ "$(echo "$OUT" | wc -l)" = "7" ] || fail "expected 7 responses, got $(echo "$OUT" | wc -l)"; ok "7 responses for 7 requests (notification ignored)"
[ "$(L 1 | J "['result']['protocolVersion']")" = "2025-06-18" ] || fail init-proto; ok "initialize echoes protocolVersion"
[ "$(L 1 | J "['result']['serverInfo']['name']")" = "peage-mcp" ] || fail init-name; ok "serverInfo present"
[ "$(L 2 | J "['result']")" = "{}" ] || fail ping; ok "ping -> {}"
[ "$(L 3 | J "['result']['tools'].__len__()")" = "7" ] || fail tools-count; ok "tools/list has 7 tools"
L 3 | J "['result']['tools'][3]['inputSchema']['required']" | grep -q url || fail schema; ok "paid_request schema has required url"
[ "$(L 4 | J "['result']['isError']")" = "False" ] || fail solvency-call; ok "peage_solvency call works (live rail)"
L 4 | python3 -c "import json,sys; r=json.load(sys.stdin); inner=json.loads(r['result']['content'][0]['text']); assert inner['solvent'] is True, inner" || fail solvency-inner; ok "solvency text is valid JSON, solvent:true"
[ "$(L 5 | J "['result']['isError']")" = "True" ] || fail status-nowallet; ok "peage_status without wallet -> isError"
L 5 | J "['result']['content'][0]['text']" | grep -q peage_setup || fail status-hint; ok "no-wallet error tells the agent to run peage_setup"
[ "$(L 6 | J "['error']['code']")" = "-32602" ] || fail unknown-tool; ok "unknown tool -> -32602"
[ "$(L 7 | J "['error']['code']")" = "-32601" ] || fail unknown-method; ok "unknown method -> -32601"

echo "ALL $PASS TESTS PASSED"
