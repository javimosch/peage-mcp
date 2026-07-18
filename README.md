# peage-mcp — give your agent a wallet

An [MCP](https://modelcontextprotocol.io) server that puts a prepaid **fiat** wallet in
any MCP-capable agent (Claude Code, Claude Desktop, anything speaking MCP stdio).
The agent can then **pay APIs per call** on the [peage rail](https://peage.intrane.fr)
— cents at a time, no crypto, no subscriptions, with spending caps you control.

One ~120 KB static binary, pure [machin (MFL)](https://github.com/javimosch/machin). No Node, no Python.

## Install

Grab the binary (or `./build.sh` with machin on PATH), then register it:

**Claude Code** (`.mcp.json` in your project, or `~/.claude.json` for user scope):
```json
{"mcpServers": {"peage": {"command": "/path/to/peage-mcp", "args": ["serve"]}}}
```

**Claude Desktop** (`claude_desktop_config.json`): same snippet under `mcpServers`.

## What the agent gets (7 tools)

| tool | what it does |
|---|---|
| `peage_setup` | mint the wallet once; token stored at `~/.peage-mcp.json` |
| `peage_status` | balance, escrow, caps, recent charges |
| `peage_topup` | Stripe Checkout URL → the agent hands it to you, you pay once |
| `peage_paid_request` | call any peage-metered API with the wallet attached |
| `peage_set_limits` | per-call + per-merchant daily spending caps |
| `peage_verify_receipt` | publicly verify any signed charge receipt |
| `peage_solvency` | audit the rail's live ledger invariant |

The human appears exactly once in the loop: paying the top-up link. Everything else is
the agent's business.

## The 60-second demo

Ask your agent: *"set up a peage wallet, then fetch https://peage.intrane.fr/demo/fortune
as a paid request"* — it mints a wallet that comes with **free starter credit**, so it pays
the 1-cent toll and gets its fortune **on the first try, no human needed**. When the free
credit runs out, `peage_topup` hands you a Stripe link to fund more. That's the whole
agent-payment loop — and the agent completes it before you touch your card.

## Security model

- The wallet token lives in `~/.peage-mcp.json` (or `PEAGE_WALLET_TOKEN`). Sharing it
  with a merchant API is *how they charge you* — the caps bound the exposure: default
  1€ per call / 10€ per merchant per day, adjustable via `peage_set_limits`.
- The rail stores only a hash of the token; every charge returns an HMAC-signed receipt
  anyone can verify; the ledger invariant is public (`peage_solvency`).
- `PEAGE_URL` points the server at a different rail instance (self-hosted, staging).

Sibling repos: [peage](https://github.com/javimosch/peage) (the rail, docs, skills) ·
x402: peage is a [live x402 facilitator](https://github.com/javimosch/peage/blob/master/specs/scheme-exact-peage.md).
An [intrane.fr](https://intrane.fr) product. Contact: javi@intrane.fr
