# Getting peage-mcp into the MCP registries

The distribution play: agents are configured *through* MCP, so the registries are where the
demand shops. This is the submission playbook — what's done, and the exact remaining action
for each target. Items marked **[needs go]** are public submissions under javimosch's identity;
everything else is prepped in this repo.

## Ready now (no packaging needed)

### 1. awesome-mcp-servers  — the canonical community list  ✅ PR OPEN
Repo: https://github.com/punkpeye/awesome-mcp-servers (Finance & Fintech section).
**PR: https://github.com/punkpeye/awesome-mcp-servers/pull/10381** (placed after `forum-labs/payfetch`).
Entry used:

```markdown
- [javimosch/peage-mcp](https://github.com/javimosch/peage-mcp) 🏎️ ☁️ — Give your agent a prepaid **fiat** wallet: pay any API per call in cents (no crypto, no subscriptions), with spending caps and publicly verifiable signed receipts. One static binary.
```
Legend used by the list: 🏎️ = Go/native (single binary), ☁️ = cloud service. Fork → add the
line → PR. Also mirror into our own `awesome-machin`.

### 2. glama.ai  — auto-indexes from GitHub  ✅ done
Adds any public repo with MCP topics + a clear README. Topics were set
(`mcp`, `model-context-protocol`, `mcp-server`, …) so glama should pick it up on its next
crawl. Verify at https://glama.ai/mcp/servers and claim the listing if it appears.

### 3. mcp.so  — community directory  **[needs go: submit URL]**
Submit the repo at https://mcp.so/submit (just the GitHub URL). Auto-pulls README.

## Needs a package artifact first

### 4. Official MCP registry (registry.modelcontextprotocol.io)  ✅ PUBLISHED
**Live as `fr.intrane/peage-mcp` v0.1.2 (status: active).** Query:
`curl -s 'https://registry.modelcontextprotocol.io/v0/servers?search=peage'`
- [x] `server.json` — schema `2025-12-11`, mcpb package pinned to the `v0.1.2` release + `fileSha256`.
- [x] `.mcpb` bundle via `./package.sh`; GitHub release v0.1.2 (extract-and-run verified).
- [x] **DNS auth** on `intrane.fr` (not GitHub) → the branded `fr.intrane/*` namespace.

**Re-publishing a new version:** bump `version` + the mcpb URL/`fileSha256`, then
`mcp-publisher login dns --domain intrane.fr --private-key <hex>` and `mcp-publisher publish`.
The auth key is in the vault-adjacent backup `~/backups/peage-mcp/mcp-registry-dns.txt`
(and the apex TXT `v=MCPv1; k=ed25519; p=…` on intrane.fr must stay in DNS). If the key is
lost, generate a new ed25519 pair and update the apex TXT — that re-grants the namespace.

### Cross-platform binaries
- **Linux/x86_64** — shipped (v0.1.2 `.mcpb`, in the registry).
- **macOS (universal: x86_64 + arm64)** — cross-compiled from Linux via `scripts/xbuild-macos.sh`
  (zig + zig-built static OpenSSL). Structurally verified: valid universal Mach-O, both slices,
  **only `/usr/lib/libSystem.B.dylib`** as a dep, no undefined symbols. **Not yet run on real
  macOS** — smoke-test `./peage-mcp version` on a Mac before adding it to `server.json`.
  Reproduce: `./scripts/xbuild-macos.sh arm64` / `x86_64`.
- **Windows** — blocked: machin's runtime C is POSIX-only (sockets/pthread/termios/mmap), so
  `zig cc -target x86_64-windows` fails at `sys/socket.h`. Needs a runtime port (winsock/win32),
  tracked in **[machin#517](https://github.com/javimosch/machin/issues/517)** — not a bundle problem.

### 5. Smithery (smithery.ai)  — lower priority
Smithery is hosted and expects a Docker/npm deployable; a local stdio binary is an awkward
fit. Revisit if we ship a container image. Not blocking.

## Status
- [x] Repo README registry-quality; free-starter-credit demo (agent pays on first call).
- [x] GitHub discovery topics set (unlocks glama / mcp.so auto-indexers).
- [x] `server.json` staged for the official registry.
- [ ] awesome-mcp-servers PR **[needs go]**
- [ ] mcp.so submit **[needs go]**
- [ ] `.mcpb` release + official-registry publish **[needs go]**
