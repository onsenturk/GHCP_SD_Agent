# copilot-agent-toolkit

A lightweight governance repository for AI-assisted software delivery using GitHub Copilot.

## What this repository does

This repo defines a **delivery framework** that ensures Copilot-generated changes follow consistent engineering standards. It provides:

- **Agents** — specialized Copilot personas for implementation, security, DevOps, architecture, and more
- **Instruction files** — auto-applied rules for security, markdown, shell scripts, and context engineering
- **Skills** — domain-specific knowledge packs for GitHub Actions, CodeQL, Dependabot, Azure pricing, and more
- **Workspace MCP servers** — Work IQ, Playwright, Sequential Thinking, Awesome Copilot catalog, and Microsoft Docs
- Mandatory engineering rules (`.github/agents/engineering-standards.agent.md`)
- A strict Definition of Done checklist (`.github/agents/dod.agent.md`)
- Global Copilot execution instructions (`.github/copilot-instructions.md`)

In short: this repository is a **policy + process layer** for implementation quality, security, architecture discipline, and documentation completeness.

## Prerequisites

| Requirement | Required for | Check |
|---|---|---|
| **VS Code** with CLI on PATH | Extensions, workspace | `code --version` |
| **GitHub Copilot** license | All agent/skill functionality | Sign in via VS Code |
| **Node.js** (v18+) | Work IQ, Playwright, Sequential Thinking MCP servers | `node --version` |
| **Docker Desktop** | Awesome Copilot MCP server (catalog search) | `docker --version` |

> **Note:** Node.js and Docker are only needed for the MCP servers in `.vscode/mcp.json`. Agents, skills, and instructions work without them.

## MCP Servers

Workspace-level servers (`.vscode/mcp.json`) — available automatically when you open the repo:

| Server | Transport | Purpose |
|---|---|---|
| **Work IQ** | `npx @microsoft/workiq` | Query Microsoft 365 data — emails, meetings, documents, Teams messages |
| **Playwright** | `npx @playwright/mcp` | Browser automation, testing, screenshots, and web interaction |
| **Sequential Thinking** | `npx @modelcontextprotocol/server-sequential-thinking` | Structured reasoning for complex planning and architecture decisions |
| **Awesome Copilot** | `docker` (stdio) | Runtime search/load of the [awesome-copilot](https://awesome-copilot.github.com/) community catalog |
| **Microsoft Docs** | `https://learn.microsoft.com/api/mcp` (http) | Microsoft Learn documentation search, code sample search, and page fetch |

User-level servers (registered by the setup script or manually) — shared across all workspaces:

| Server | Purpose |
|---|---|
| **GitHub** | GitHub operations — issues, PRs, repos, branches, files, releases, search |
| **Azure** | Azure resource management, deployment, diagnostics, and best practices |
| **Bicep** | Bicep file authoring, validation, and ARM template decompilation |
| **PostgreSQL** | PostgreSQL database querying, schema exploration, and dashboards |
| **Pylance** | Python language features — docs, imports, refactoring, syntax errors |
| **Foundry** | Microsoft Foundry agent management — deploy, evaluate, optimize prompts |

## Repository structure

```text
.
├── .github/
│   ├── copilot-instructions.md          # Orchestration — agents, skills, workflow rules
│   ├── agents/
│   │   ├── adr-generator.agent.md
│   │   ├── devops-expert.agent.md
│   │   ├── dod.agent.md                  # Definition of Done checklist
│   │   ├── engineering-standards.agent.md # Architecture, security, infra, AI/ML standards
│   │   ├── github-actions-expert.agent.md
│   │   ├── implementation-template.agent.md # New feature / bug fix / refactor template
│   │   ├── marketing.agent.md            # Monetization modeling agent
│   │   ├── repo-architect.agent.md
│   │   ├── se-security-reviewer.agent.md
│   │   └── ux.agent.md                   # UI/UX design agent
│   ├── instructions/
│   │   ├── agent-safety.instructions.md
│   │   ├── agents.instructions.md
│   │   ├── bicep.instructions.md
│   │   ├── context-engineering.instructions.md
│   │   ├── markdown-gfm.instructions.md
│   │   ├── powershell.instructions.md
│   │   ├── security-and-owasp.instructions.md
│   │   └── shell.instructions.md
│   └── skills/                           # Each skill has SKILL.md + SOURCE.md (upstream SHA)
│       ├── apple-appstore-reviewer/
│       ├── architecture-blueprint-generator/
│       ├── az-cost-optimize/
│       ├── azure-pricing/
│       ├── azure-resource-visualizer/
│       ├── cloud-design-patterns/
│       ├── codeql/
│       ├── create-implementation-plan/
│       ├── creating-oracle-to-postgres-master-migration-plan/
│       ├── dependabot/
│       ├── foundry-agent-sync/
│       ├── git-commit/
│       ├── github-issues/
│       ├── gtm-0-to-1-launch/
│       └── secret-scanning/
├── .vscode/
│   ├── extensions.json                  # Recommended VS Code extensions
│   └── mcp.json                         # Workspace MCP server configuration
├── azure.md                             # Azure tenant/subscription context (edit after fork)
└── scripts/
    ├── init-setup.ps1                   # Windows setup script
    ├── init-setup.sh                    # macOS/Linux setup script
    ├── install-global.ps1               # Install user-level MCP servers
    └── sync-skills.ps1                  # Sync skills from github/awesome-copilot
```

## Agents

| Agent | Invoke with | Purpose |
|---|---|---|
| **Implementation Template** | `@implementation-template` | Implementing a new feature, fixing a bug, refactoring, or modifying existing behavior |
| **Engineering Standards** | `@engineering-standards` | Review architecture, security, infrastructure, and coding compliance |
| **Definition of Done** | `@dod` | Validate task completion before marking done |
| **UX** | `@ux` | UI/frontend work — opinionated design patterns, component selection, layout |
| **Marketing** | `@marketing` | Monetization modeling — cost structure and revenue projections |
| **GitHub Actions Expert** | `@github-actions-expert` | CI/CD workflows, action pinning, OIDC auth, supply-chain security |
| **Security Reviewer** | `@se-security-reviewer` | OWASP Top 10, Zero Trust, LLM security, enterprise security review |
| **ADR Generator** | `@adr-generator` | Architectural Decision Records with structured formatting |
| **DevOps Expert** | `@devops-expert` | DevOps infinity loop — Plan, Code, Build, Test, Release, Deploy, Operate, Monitor |
| **Repo Architect** | `@repo-architect` | Validate/scaffold agentic project structures and Copilot customization files |

## Skills

Skills are auto-loaded from `.github/skills/` and triggered by matching prompts:

| Skill | Trigger |
|---|---|
| `create-implementation-plan` | Planning a new feature, refactor, package upgrade, or design change |
| `git-commit` | Committing changes — conventional commits, intelligent staging, auto-generated messages |
| `github-issues` | Creating, updating, or managing GitHub issues (bug reports, features, labels, milestones) |
| `architecture-blueprint-generator` | Generating architecture documentation, detecting patterns, creating visual diagrams |
| `codeql` | Setting up CodeQL code scanning, GitHub Actions workflows for SAST, or CodeQL CLI |
| `dependabot` | Configuring `dependabot.yml`, dependency update strategies, grouped updates |
| `secret-scanning` | Enabling secret scanning, push protection, custom patterns, or remediating alerts |
| `cloud-design-patterns` | Designing distributed systems — reliability, messaging, performance, security patterns |
| `azure-pricing` | Estimating Azure costs, comparing SKUs, fetching real-time pricing data |
| `az-cost-optimize` | Auditing Azure resources for cost savings, analyzing IaC files for optimization |
| `azure-resource-visualizer` | Generating Mermaid diagrams of Azure resource groups and their relationships |
| `apple-appstore-reviewer` | Reviewing code for App Store compliance, optimization, or common rejection reasons |
| `gtm-0-to-1-launch` | Go-to-market planning, finding early adopters, building launch playbooks |
| `creating-oracle-to-postgres-master-migration-plan` | Assessing .NET projects for Oracle-to-PostgreSQL migration |
| `foundry-agent-sync` | Creating, syncing, deploying, or updating AI agents in Azure AI Foundry |

### Keeping skills in sync with upstream

Local skill folders are copies from [`github/awesome-copilot`](https://github.com/github/awesome-copilot)
under `skills/<name>/`. Each folder has a `SOURCE.md` that records the upstream commit SHA it was
last synced from.

Use [scripts/sync-skills.ps1](scripts/sync-skills.ps1) to manage them:

```powershell
# Sync every local skill to the latest upstream commit
pwsh ./scripts/sync-skills.ps1

# Sync a single skill
pwsh ./scripts/sync-skills.ps1 -SkillName codeql

# CI-friendly drift detection (exits non-zero if any skill is out of date)
pwsh ./scripts/sync-skills.ps1 -Check

# Force re-download even if SOURCE.md says the skill is current
pwsh ./scripts/sync-skills.ps1 -Force
```

Set `$env:GITHUB_TOKEN` before running to avoid the unauthenticated GitHub API rate limit.
The script never adds new skills — to onboard a new one, create an empty folder under
`.github/skills/<name>/` and then run the sync.

## Instructions

Instruction files in `.github/instructions/` are auto-applied based on `applyTo` glob patterns:

| Instruction | Applies to | Purpose |
|---|---|---|
| `agent-safety` | All files | Safe AI agent system guidelines — governance, tool access, audit |
| `agents` | `*.agent.md` files | Meta-instructions for creating custom agent files |
| `context-engineering` | All files | Structuring code for maximum Copilot effectiveness |
| `markdown-gfm` | `*.md` files | GitHub-flavored markdown formatting rules |
| `security-and-owasp` | All files | OWASP Top 10 secure coding practices |
| `shell` | `*.sh` files | Shell scripting best practices and conventions |

## Getting Started (New Machine / Fresh Clone)

### Automated Setup

**Windows (PowerShell):**
```powershell
.\scripts\init-setup.ps1            # full setup
.\scripts\init-setup.ps1 -DryRun    # preview changes without applying
```

**macOS / Linux (Bash):**
```bash
chmod +x scripts/init-setup.sh
./scripts/init-setup.sh              # full setup
./scripts/init-setup.sh --dry-run    # preview changes without applying
```

The script will:
1. Check prerequisites (VS Code, Node.js, Docker)
2. Install recommended VS Code extensions (Copilot, Azure, Bicep, Pylance, PostgreSQL, Foundry)
3. Register user-level MCP servers (GitHub MCP, Microsoft Docs MCP) if not already configured
4. Validate the workspace config files exist

Use `--skip-extensions` or `--skip-mcp` to skip individual steps.

### Manual Setup (if you prefer)

1. Install the extensions listed in `.vscode/extensions.json` (VS Code will prompt on first open)
2. Add these to your user-level `mcp.json` (File > Preferences > MCP Servers, or via MCP Gallery):
   - **GitHub MCP** — `https://api.githubcopilot.com/mcp/`
   - **Microsoft Docs MCP** — `https://learn.microsoft.com/api/mcp`

### After Setup

1. **Edit `azure.md`** — fill in your Azure tenant ID, subscription, and resource group (or leave blank if not using Azure)
2. (Optional) Sign in to Azure CLI: `az login`
3. (Optional) Start Docker Desktop for the Awesome Copilot MCP server
4. Start chatting — try `@implementation-template`, `@dod`, `@se-security-reviewer`

## How to use it

1. Use `@implementation-template` to scope new features, bug fixes, or refactors.
2. Copilot will follow the mandatory workflow from `copilot-instructions.md`.
3. Implementation only begins after impact, security, architecture, and infrastructure analysis.
4. Use `@dod` to validate completion before marking work done.
5. Use `@engineering-standards` to review compliance at any point.
6. Use `@se-security-reviewer` for security-focused code review.
7. Use `@github-actions-expert` when building CI/CD pipelines.

## Core principles enforced

- Layered architecture compliance
- Strong security hygiene (OWASP-minded defaults)
- Documentation-first discipline
- Minimal scope creep and no unrelated refactors
- Azure-first infrastructure expectations

## Intended audience

- Teams using Copilot for implementation tasks
- Engineers who need consistent review gates
- Tech leads enforcing architecture and security standards