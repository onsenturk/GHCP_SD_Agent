#!/usr/bin/env bash
#
# init-setup.sh — Initializes a fresh dev environment for GHCP_SD_Agent
#
# Usage: ./scripts/init-setup.sh [--skip-extensions] [--skip-mcp] [--dry-run]

set -euo pipefail

SKIP_EXTENSIONS=false
SKIP_MCP=false
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --skip-extensions) SKIP_EXTENSIONS=true ;;
    --skip-mcp)        SKIP_MCP=true ;;
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

# ─── User-level MCP servers ─────────────────────────────────────────────────

if [[ "$(uname)" == "Darwin" ]]; then
  USER_MCP_PATH="$HOME/Library/Application Support/Code/User/mcp.json"
else
  USER_MCP_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User/mcp.json"
fi

if [[ "$SKIP_MCP" == false ]]; then
  step "Configuring user-level MCP servers ($USER_MCP_PATH)"

  # Ensure directory exists
  mkdir -p "$(dirname "$USER_MCP_PATH")"

  if [[ -f "$USER_MCP_PATH" ]]; then
    EXISTING=$(cat "$USER_MCP_PATH")
  else
    EXISTING='{"servers":{},"inputs":[]}'
  fi

  # Check and add GitHub MCP if missing
  if echo "$EXISTING" | grep -q "io.github.github/github-mcp-server"; then
    ok "GitHub MCP (already configured)"
  else
    if [[ "$DRY_RUN" == true ]]; then
      printf '   \033[35m[DRY-RUN]\033[0m Would add GitHub MCP server\n'
    else
      if command -v python3 &>/dev/null; then
        EXISTING=$(echo "$EXISTING" | python3 -c "
import sys, json
data = json.load(sys.stdin)
data.setdefault('servers', {})
data['servers']['io.github.github/github-mcp-server'] = {
    'type': 'http',
    'url': 'https://api.githubcopilot.com/mcp/',
    'gallery': 'https://api.mcp.github.com',
    'version': '0.32.0'
}
json.dump(data, sys.stdout, indent=2)
")
        echo "$EXISTING" > "$USER_MCP_PATH"
        ok "GitHub MCP added"
      else
        warn "python3 not found — cannot update mcp.json. Add GitHub MCP manually."
      fi
    fi
  fi

  # Re-read in case it was just written
  if [[ -f "$USER_MCP_PATH" ]]; then EXISTING=$(cat "$USER_MCP_PATH"); fi

  # Check and add Microsoft Docs MCP if missing
  if echo "$EXISTING" | grep -q "microsoftdocs/mcp"; then
    ok "Microsoft Docs MCP (already configured)"
  else
    if [[ "$DRY_RUN" == true ]]; then
      printf '   \033[35m[DRY-RUN]\033[0m Would add Microsoft Docs MCP server\n'
    else
      if command -v python3 &>/dev/null; then
        EXISTING=$(echo "$EXISTING" | python3 -c "
import sys, json
data = json.load(sys.stdin)
data.setdefault('servers', {})
data['servers']['microsoftdocs/mcp'] = {
    'type': 'http',
    'url': 'https://learn.microsoft.com/api/mcp',
    'gallery': 'https://api.mcp.github.com',
    'version': '1.0.0'
}
json.dump(data, sys.stdout, indent=2)
")
        echo "$EXISTING" > "$USER_MCP_PATH"
        ok "Microsoft Docs MCP added"
      else
        warn "python3 not found — cannot update mcp.json. Add Microsoft Docs MCP manually."
      fi
    fi
  fi
else
  step "Skipping MCP configuration (--skip-mcp)"
fi

# ─── Workspace validation ───────────────────────────────────────────────────

step "Validating workspace configuration"

if [[ -f "$REPO_DIR/.vscode/mcp.json" ]]; then
  ok ".vscode/mcp.json exists (workiq, playwright, sequential-thinking, awesome-copilot)"
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
