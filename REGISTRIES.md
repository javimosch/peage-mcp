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

### 4. Official MCP registry (registry.modelcontextprotocol.io)  **[needs go: one command]**
Staged and ready — only the final publish (GitHub OAuth) remains:
- [x] `server.json` in this repo (`io.github.javimosch/peage-mcp`, mcpb transport).
- [x] `.mcpb` bundle built via `./package.sh` (manifest + linux binary; extract-and-run verified).
- [x] GitHub release **v0.1.2** cut with `peage-mcp.mcpb` attached; the `releases/latest/download/peage-mcp.mcpb` URL in `server.json` resolves (HTTP 200).
- [ ] `mcp-publisher login github` (OAuth as javimosch → owns `io.github.javimosch/*`, no DNS proof needed) then `mcp-publisher publish`. **[needs go]**

Note: the bundled binary is **linux/x86_64**. Most Claude Desktop users are mac/windows, so
a cross-compiled bundle (machin → darwin/windows) is the follow-up that widens reach.

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
