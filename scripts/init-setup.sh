#!/usr/bin/env bash
#
# init-setup.sh — Initializes a fresh dev environment for copilot-agent-toolkit
#
# All MCP servers are configured at the workspace level in .vscode/mcp.json
# and activate automatically when the repo is opened in VS Code.
#
# Usage: ./scripts/init-setup.sh [--skip-extensions] [--dry-run]

set -euo pipefail

SKIP_EXTENSIONS=false
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --skip-extensions) SKIP_EXTENSIONS=true ;;
    --dry-run)         DRY_RUN=true ;;
    *) echo "Unknown flag: $arg"; exit 1 ;;
  esac
done

step()  { printf '\n\033[36m>> %s\033[0m\n' "$1"; }
ok()    { printf '   \033[32m[OK]\033[0m %s\n' "$1"; }
warn()  { printf '   \033[33m[WARN]\033[0m %s\n' "$1"; }
fail()  { printf '   \033[31m[FAIL]\033[0m %s\n' "$1"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# ─── Prerequisites ───────────────────────────────────────────────────────────

step "Checking prerequisites"

CODE_AVAILABLE=false
if command -v code &>/dev/null; then
  ok "VS Code CLI available"
  CODE_AVAILABLE=true
else
  warn "VS Code CLI (code) not on PATH — extension install will be skipped."
fi

# Node.js (required for npx-based MCP servers)
if command -v node &>/dev/null; then
  ok "Node.js available ($(node --version))"
else
  warn "Node.js not found — MCP servers (workiq, playwright, sequential-thinking) require Node.js 18+."
fi

# Docker (required for awesome-copilot MCP server)
if command -v docker &>/dev/null; then
  ok "Docker available"
else
  warn "Docker not found — the awesome-copilot MCP server requires Docker Desktop."
fi

# ─── VS Code Extensions ─────────────────────────────────────────────────────

EXTENSIONS=(
  "github.copilot"
  "github.copilot-chat"
  "github.vscode-pull-request-github"
  "ms-azuretools.vscode-azure-github-copilot"
  "ms-azuretools.vscode-bicep"
  "ms-python.vscode-pylance"
  "ms-ossdata.vscode-postgresql"
  "ms-windows-ai-studio.windows-ai-studio"
)

if [[ "$SKIP_EXTENSIONS" == false ]] && [[ "$CODE_AVAILABLE" == true ]]; then
  step "Installing recommended VS Code extensions"
  INSTALLED=$(code --list-extensions 2>/dev/null || true)
  for ext in "${EXTENSIONS[@]}"; do
    if echo "$INSTALLED" | grep -qi "^${ext}$"; then
      ok "$ext (already installed)"
    else
      if [[ "$DRY_RUN" == true ]]; then
        printf '   \033[35m[DRY-RUN]\033[0m Would install %s\n' "$ext"
      else
        printf '   Installing %s ...\n' "$ext"
        code --install-extension "$ext" --force >/dev/null 2>&1 || warn "Failed to install $ext"
        ok "$ext"
      fi
    fi
  done
elif [[ "$SKIP_EXTENSIONS" == true ]]; then
  step "Skipping VS Code extensions (--skip-extensions)"
else
  step "Skipping VS Code extensions (code CLI not found)"
fi

# ─── Workspace validation ───────────────────────────────────────────────────

step "Validating workspace configuration"

if [[ -f "$REPO_DIR/.vscode/mcp.json" ]]; then
  ok ".vscode/mcp.json exists (workiq, playwright, sequential-thinking, awesome-copilot, microsoftdocs, azure, github)"
else
  warn ".vscode/mcp.json not found — workspace MCP servers will not be available"
fi

if [[ -f "$REPO_DIR/.github/copilot-instructions.md" ]]; then
  ok ".github/copilot-instructions.md exists"
else
  warn ".github/copilot-instructions.md not found"
fi

# ─── Summary ─────────────────────────────────────────────────────────────────

printf '\n\033[36m========================================\033[0m\n'
printf '\033[36m  Setup complete!\033[0m\n'
printf '\033[36m========================================\033[0m\n\n'
echo "Next steps:"
echo "  1. Open this folder in VS Code"
echo "  2. Accept the recommended extensions prompt"
echo "  3. Sign in to GitHub Copilot"
echo "  4. (Optional) Sign in to Azure CLI: az login"
echo "  5. (Optional) Start Docker Desktop for the awesome-copilot MCP server"
echo "  6. Start chatting — use @implementation-template, @dod, @se-security-reviewer, @github-actions-expert"
echo ""
