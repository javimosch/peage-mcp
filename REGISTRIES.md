# Getting peage-mcp into the MCP registries

The distribution play: agents are configured *through* MCP, so the registries are where the
demand shops. This is the submission playbook — what's done, and the exact remaining action
for each target. Items marked **[needs go]** are public submissions under javimosch's identity;
everything else is prepped in this repo.

## Ready now (no packaging needed)

### 1. awesome-mcp-servers  — the canonical community list  **[needs go: open a PR]**
Repo: https://github.com/punkpeye/awesome-mcp-servers (Finance / Payments section).
Ready-to-paste entry (alphabetical within the section):

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

### 4. Official MCP registry (registry.modelcontextprotocol.io)  **[needs go]**
`server.json` is staged in this repo (`io.github.javimosch/peage-mcp`, mcpb transport).
peage-mcp is a single static binary, so the registry-native distribution is an **`.mcpb`
bundle** attached to a GitHub release. Steps:
1. `./build.sh` then package the binary + a `manifest.json` into `peage-mcp.mcpb` (a zip).
2. Cut a GitHub release `v0.1.0`, attach `peage-mcp.mcpb`.
3. `mcp-publisher login github` (OAuth as javimosch → owns the `io.github.javimosch/*` namespace).
4. `mcp-publisher publish` (reads `server.json`).
The `io.github.javimosch/*` namespace needs no DNS proof — GitHub auth is enough. A
`fr.intrane/peage-mcp` name would need an intrane.fr DNS TXT record instead.

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
