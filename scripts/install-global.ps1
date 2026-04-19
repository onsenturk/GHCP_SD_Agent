#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Installs copilot-agent-toolkit instructions, agents, and skills as user-level
    VS Code Copilot customizations so they apply to every workspace.

.DESCRIPTION
    Copies:
      - .github/instructions/*.instructions.md → VS Code user prompts folder
      - .github/agents/*.agent.md             → VS Code user prompts folder
      - .github/skills/*/                     → ~/.agents/skills/
      - .github/copilot-instructions.md       → VS Code user setting

    MCP servers from .vscode/mcp.json must be added to VS Code User Settings
    manually (or via `code --edit-settings`), since they require merging.

.PARAMETER Force
    Overwrite existing files without prompting.
#>
[CmdletBinding()]
param(
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------- paths ----------
# $PSScriptRoot is the scripts/ folder; the repo root is one level up.
$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $repoRoot '.github'))) {
    throw "Could not locate .github folder relative to script (expected at $repoRoot\.github)."
}

$userPromptsFolder = Join-Path $env:APPDATA 'Code\User\prompts'
$userSkillsFolder  = Join-Path $HOME '.agents\skills'

$srcInstructions   = Join-Path $repoRoot '.github\instructions'
$srcAgents         = Join-Path $repoRoot '.github\agents'
$srcSkills         = Join-Path $repoRoot '.github\skills'

# ---------- helpers ----------
function Copy-FileSafe {
    param(
        [string]$Source,
        [string]$Destination
    )
    $destDir = Split-Path -Parent $Destination
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    if ((Test-Path $Destination) -and -not $Force) {
        Write-Warning "Skipping (exists): $Destination  — use -Force to overwrite"
        return
    }
    Copy-Item -Path $Source -Destination $Destination -Force
    Write-Host "  Copied → $Destination"
}

function Copy-DirectorySafe {
    param(
        [string]$Source,
        [string]$Destination
    )
    if ((Test-Path $Destination) -and -not $Force) {
        Write-Warning "Skipping (exists): $Destination  — use -Force to overwrite"
        return
    }
    # Remove existing target before recursive copy to avoid Copy-Item nesting
    # the source folder INSIDE an existing destination of the same name.
    if (Test-Path $Destination) {
        Remove-Item -Path $Destination -Recurse -Force
    }
    $parent = Split-Path -Parent $Destination
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    Copy-Item -Path $Source -Destination $Destination -Recurse -Force
    Write-Host "  Copied → $Destination"
}

# ---------- 1. Instructions → user prompts ----------
Write-Host "`n=== Installing instruction files ===" -ForegroundColor Cyan
if (Test-Path $srcInstructions) {
    foreach ($file in Get-ChildItem -Path $srcInstructions -Filter '*.instructions.md') {
        Copy-FileSafe -Source $file.FullName -Destination (Join-Path $userPromptsFolder $file.Name)
    }
}
else {
    Write-Warning "No instructions folder found at $srcInstructions"
}

# ---------- 2. Agents → user prompts ----------
Write-Host "`n=== Installing agent files ===" -ForegroundColor Cyan
if (Test-Path $srcAgents) {
    foreach ($file in Get-ChildItem -Path $srcAgents -Filter '*.agent.md') {
        Copy-FileSafe -Source $file.FullName -Destination (Join-Path $userPromptsFolder $file.Name)
    }
}
else {
    Write-Warning "No agents folder found at $srcAgents"
}

# ---------- 3. Skills → ~/.agents/skills ----------
Write-Host "`n=== Installing skill folders ===" -ForegroundColor Cyan
if (Test-Path $srcSkills) {
    foreach ($skillDir in Get-ChildItem -Path $srcSkills -Directory) {
        $dest = Join-Path $userSkillsFolder $skillDir.Name
        Copy-DirectorySafe -Source $skillDir.FullName -Destination $dest
    }
}
else {
    Write-Warning "No skills folder found at $srcSkills"
}

# ---------- 4. Summary ----------
Write-Host "`n=== Installation complete ===" -ForegroundColor Green
Write-Host "  User prompts:  $userPromptsFolder"
Write-Host "  User skills:   $userSkillsFolder"
Write-Host ""
Write-Host "Remaining manual steps:" -ForegroundColor Yellow
Write-Host "  1. MCP servers: Open VS Code User Settings (JSON) and merge"
Write-Host "     the servers from .vscode/mcp.json into 'mcp.servers'."
Write-Host "  2. Restart VS Code to pick up the new files."
Write-Host ""
