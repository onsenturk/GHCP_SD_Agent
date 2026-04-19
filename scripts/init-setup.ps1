<#
.SYNOPSIS
    Initializes a fresh development environment for copilot-agent-toolkit.

.DESCRIPTION
    - Installs recommended VS Code extensions
    - Validates the workspace MCP config exists

    All MCP servers are configured at the workspace level in .vscode/mcp.json
    and activate automatically when the repo is opened in VS Code.

.NOTES
    Run from the repository root: .\scripts\init-setup.ps1
#>

param(
    [switch]$SkipExtensions,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step { param([string]$Message) Write-Host "`n>> $Message" -ForegroundColor Cyan }
function Write-Ok   { param([string]$Message) Write-Host "   [OK] $Message" -ForegroundColor Green }
function Write-Warn { param([string]$Message) Write-Host "   [WARN] $Message" -ForegroundColor Yellow }
function Write-Err  { param([string]$Message) Write-Host "   [FAIL] $Message" -ForegroundColor Red }

# ─── Prerequisites ───────────────────────────────────────────────────────────

Write-Step "Checking prerequisites"

# VS Code CLI
$code = Get-Command code -ErrorAction SilentlyContinue
if ($code) { Write-Ok "VS Code CLI available" } else { Write-Warn "VS Code CLI (code) not on PATH — extension install will be skipped." }

# Node.js (required for npx-based MCP servers)
$node = Get-Command node -ErrorAction SilentlyContinue
if ($node) { Write-Ok "Node.js available ($(& node --version))" } else { Write-Warn "Node.js not found — MCP servers (workiq, playwright, sequential-thinking) require Node.js 18+." }

# Docker (required for awesome-copilot MCP server)
$docker = Get-Command docker -ErrorAction SilentlyContinue
if ($docker) { Write-Ok "Docker available" } else { Write-Warn "Docker not found — the awesome-copilot MCP server requires Docker Desktop." }

# ─── VS Code Extensions ─────────────────────────────────────────────────────

$extensions = @(
    "github.copilot",
    "github.copilot-chat",
    "github.vscode-pull-request-github",
    "ms-azuretools.vscode-azure-github-copilot",
    "ms-azuretools.vscode-bicep",
    "ms-python.vscode-pylance",
    "ms-ossdata.vscode-postgresql",
    "ms-windows-ai-studio.windows-ai-studio"
)

if (-not $SkipExtensions -and $code) {
    Write-Step "Installing recommended VS Code extensions"
    $installed = & code --list-extensions 2>$null
    foreach ($ext in $extensions) {
        if ($installed -contains $ext) {
            Write-Ok "$ext (already installed)"
        } else {
            if ($DryRun) {
                Write-Host "   [DRY-RUN] Would install $ext" -ForegroundColor Magenta
            } else {
                Write-Host "   Installing $ext ..." -ForegroundColor Gray
                & code --install-extension $ext --force 2>$null | Out-Null
                Write-Ok "$ext"
            }
        }
    }
} elseif ($SkipExtensions) {
    Write-Step "Skipping VS Code extensions (-SkipExtensions)"
} else {
    Write-Step "Skipping VS Code extensions (code CLI not found)"
}

# ─── Workspace MCP validation ───────────────────────────────────────────────

Write-Step "Validating workspace configuration"

$workspaceMcp = Join-Path $PSScriptRoot "..\.vscode\mcp.json"
if (Test-Path $workspaceMcp) {
    Write-Ok ".vscode/mcp.json exists (workiq, playwright, sequential-thinking, awesome-copilot, microsoftdocs, azure, github)"
} else {
    Write-Warn ".vscode/mcp.json not found — workspace MCP servers will not be available"
}

$copilotInstructions = Join-Path $PSScriptRoot "..\.github\copilot-instructions.md"
if (Test-Path $copilotInstructions) {
    Write-Ok ".github/copilot-instructions.md exists"
} else {
    Write-Warn ".github/copilot-instructions.md not found"
}

# ─── Summary ─────────────────────────────────────────────────────────────────

Write-Host "`n" -NoNewline
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Open this folder in VS Code" -ForegroundColor Gray
Write-Host "  2. Accept the recommended extensions prompt (or run: code --install-extension from list)" -ForegroundColor Gray
Write-Host "  3. Sign in to GitHub Copilot" -ForegroundColor Gray
Write-Host "  4. (Optional) Sign in to Azure CLI: az login" -ForegroundColor Gray
Write-Host "  5. (Optional) Start Docker Desktop for the awesome-copilot MCP server" -ForegroundColor Gray
Write-Host "  6. Start chatting — use @implementation-template, @dod, @se-security-reviewer, @github-actions-expert" -ForegroundColor Gray
Write-Host ""
