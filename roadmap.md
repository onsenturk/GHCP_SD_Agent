# Roadmap

Planned but not-yet-implemented changes to the toolkit. Items here are intentionally deferred — not abandoned.

---

## MCP-server distribution model

**Status**: Deferred. Current `pull-toolkit.ps1` / `install-global.ps1` flow stays in place for now.

### Goal

Replace per-repo file copying with a hosted MCP server so consumers register one URL and always get the latest agents, skills, and standards — no script execution, no drift.

### Target end-state for a consumer repo

```
consumer-repo/
├── .vscode/mcp.json                  # 1 entry: copilot-toolkit MCP URL
├── .github/
│   ├── copilot-instructions.md       # ~30 lines: tells Copilot to use the MCP
│   └── instructions/                 # local file-scoped rules (bicep, ps, security)
└── azure.md                          # repo-specific Azure context (optional)
```

Roughly 30 lines of config replaces the current ~80 file pull.

### Architecture

| Component | Detail |
|---|---|
| Transport | HTTP (preferred) or stdio + Docker — model after `https://learn.microsoft.com/api/mcp` |
| Server stack | TypeScript + `@modelcontextprotocol/sdk`, ~150 LOC |
| Source of truth | This repo's `main` branch via `raw.githubusercontent.com` |
| Hosting | Azure Container Apps (consumption tier) or Cloudflare Workers |
| Image | `ghcr.io/onsenturk/copilot-toolkit-mcp` (if Docker route) |

### Tools to expose

| Tool | Purpose |
|---|---|
| `list_agents()` / `list_skills()` / `list_instructions()` | Catalog with name + description |
| `search(keywords)` | Filter catalog by keyword |
| `load(name, type)` | Return raw markdown body of one item |

### Known limitations (why a slim local file is still required)

| Capability | Local file | MCP server |
|---|---|---|
| Auto-loaded into every chat | ✅ `copilot-instructions.md` | ❌ |
| `applyTo` glob auto-application | ✅ `*.instructions.md` | ❌ |
| On-demand catalog / standards | ✅ | ✅ |

So consumers will always need (a) a tiny bootstrap `copilot-instructions.md` pointing at the MCP, and (b) any `*.instructions.md` files that rely on `applyTo` globs (Bicep, PowerShell, security, etc.).

### Build checklist (when picked up)

- [ ] Scaffold `mcp-server/` — TypeScript, `@modelcontextprotocol/sdk`, three tools above
- [ ] Add Dockerfile + `.dockerignore`
- [ ] Add Bicep (Azure Container Apps + managed identity, public ingress)
- [ ] Add `consumer-template/` with the slim `.github/` + `.vscode/` layout
- [ ] Add a CI workflow that publishes the image to GHCR on tag
- [ ] Update README to recommend the MCP route as primary, keep `pull-toolkit.ps1` as fallback
- [ ] Deprecate `install-global.ps1` once the MCP is stable

### Open questions

- Auth model: public read-only vs. GitHub OAuth gate for org-only catalogs?
- Caching strategy: in-memory TTL vs. live fetch on every call (current awesome-copilot behaviour is live)?
- Should `copilot-instructions.md` itself be served by the MCP (as a one-time bootstrap fetch)?

---

## Other parked items

_Add new deferred items below as bullets — promote them to their own section once they're picked up._
