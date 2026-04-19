<#
.SYNOPSIS
    Pulls the latest .github/ and .vscode/ folders from copilot-agent-toolkit
    into the current repository.

.DESCRIPTION
    Downloads the entire contents of the .github/ and .vscode/ folders from the
    copilot-agent-toolkit repository on GitHub and writes them into the current
    working directory, overwriting any existing files WITHIN THOSE TWO FOLDERS
    ONLY.

    Safety guarantees:
      * The script never deletes any file. It only writes files that exist in
        the upstream toolkit's .github/ and .vscode/ trees.
      * Any local file whose path is NOT present in the upstream tree (for
        example .github/workflows/*.yml) is left completely untouched.
      * Each download target is validated to live inside one of the allowed
        top-level folders; path-traversal attempts are refused.

    Records the commit SHA that was pulled in .github/.toolkit-version so you
    can tell at a glance how fresh your local copy is. There is no drift
    enforcement — re-run this script whenever you want the latest.

.PARAMETER Ref
    Branch, tag, or commit SHA to pull from. Defaults to 'main'.

.PARAMETER Path
    Target directory to write files into. Defaults to the current directory.

.PARAMETER DryRun
    List the files that would be downloaded without writing anything.

.EXAMPLE
    # In a new repo, fetch latest main
    iwr https://raw.githubusercontent.com/onsenturk/copilot-agent-toolkit/main/scripts/pull-toolkit.ps1 | iex

.EXAMPLE
    # Pin to a specific tag
    pwsh ./scripts/pull-toolkit.ps1 -Ref v1.2.0

.NOTES
    Set $env:GITHUB_TOKEN to avoid the unauthenticated GitHub API rate limit
    (60 requests/hour).
#>
[CmdletBinding()]
param(
    [string] $Ref  = 'main',
    [string] $Path = (Get-Location).Path,
    [switch] $DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Owner   = 'onsenturk'
$script:Repo    = 'copilot-agent-toolkit'
$script:Folders = @('.github', '.vscode')

$apiRoot = "https://api.github.com/repos/$script:Owner/$script:Repo"
$rawRoot = "https://raw.githubusercontent.com/$script:Owner/$script:Repo/$Ref"

$headers = @{
    'User-Agent' = 'pull-toolkit.ps1'
    'Accept'     = 'application/vnd.github+json'
}
if ($env:GITHUB_TOKEN) {
    $headers['Authorization'] = "Bearer $env:GITHUB_TOKEN"
}

function Get-RemoteTree {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string] $Folder)

    $uri = "$apiRoot/contents/$Folder`?ref=$Ref"
    try {
        $entries = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
    }
    catch {
        throw "Failed to list contents of '$Folder' at ref '$Ref': $($_.Exception.Message)"
    }

    $files = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in $entries) {
        if ($entry.type -eq 'file') {
            $files.Add([pscustomobject]@{ Path = $entry.path; Sha = $entry.sha })
        }
        elseif ($entry.type -eq 'dir') {
            foreach ($child in (Get-RemoteTree -Folder $entry.path)) { $files.Add($child) }
        }
    }
    return $files
}

function Get-CommitSha {
    $uri = "$apiRoot/commits/$Ref"
    try {
        return (Invoke-RestMethod -Uri $uri -Headers $headers -Method Get).sha
    }
    catch {
        throw "Failed to resolve ref '$Ref': $($_.Exception.Message)"
    }
}

# ---------- main ----------

$resolvedSha = Get-CommitSha
Write-Host "[i] Pulling $script:Owner/$script:Repo @ $($resolvedSha.Substring(0,7)) ($Ref)" -ForegroundColor Cyan
Write-Host "[i] Target: $Path"
if ($DryRun) { Write-Host "[i] DRY-RUN: no files will be written" -ForegroundColor Magenta }

$totalFiles = 0
foreach ($folder in $script:Folders) {
    Write-Host "`n=== $folder ===" -ForegroundColor Cyan
    try {
        $files = Get-RemoteTree -Folder $folder
    }
    catch {
        Write-Warning "$folder not found at ref '$Ref' — skipping."
        continue
    }

    foreach ($file in $files) {
        # --- safety: only allow writes inside one of the configured folders ---
        $relPath = $file.Path -replace '\\', '/'
        $allowed = $false
        foreach ($f in $script:Folders) {
            if ($relPath -eq $f -or $relPath.StartsWith("$f/")) { $allowed = $true; break }
        }
        if (-not $allowed) {
            Write-Warning "  [skip] $relPath : outside allowed folders ($($script:Folders -join ', '))"
            continue
        }

        $targetPath = Join-Path $Path $file.Path
        $resolvedRoot = [System.IO.Path]::GetFullPath((Join-Path $Path '.'))
        $resolvedTarget = [System.IO.Path]::GetFullPath($targetPath)
        if (-not $resolvedTarget.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            Write-Warning "  [skip] $relPath : path escapes target directory"
            continue
        }

        $targetDir = Split-Path -Parent $targetPath

        if ($DryRun) {
            Write-Host "  [dry-run] $($file.Path)" -ForegroundColor Magenta
            $totalFiles++
            continue
        }

        if (-not (Test-Path -LiteralPath $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }

        $rawUri = "$rawRoot/$($file.Path)"
        try {
            Invoke-WebRequest -Uri $rawUri -Headers $headers -UseBasicParsing -OutFile $targetPath
            Write-Host "  [ok] $($file.Path)" -ForegroundColor Green
            $totalFiles++
        }
        catch {
            Write-Warning "  [fail] $($file.Path) : $($_.Exception.Message)"
        }
    }
}

if (-not $DryRun) {
    $versionFile = Join-Path $Path '.github/.toolkit-version'
    $versionContent = @"
# Auto-generated by pull-toolkit.ps1 — do not edit manually.
upstream_repo: $script:Owner/$script:Repo
upstream_ref:  $Ref
upstream_sha:  $resolvedSha
pulled_at:     $([DateTimeOffset]::UtcNow.ToString('o'))
"@
    Set-Content -LiteralPath $versionFile -Value $versionContent -Encoding utf8
    Write-Host "`n[i] Wrote $versionFile" -ForegroundColor Cyan
}

Write-Host "`n[done] $totalFiles file(s) processed." -ForegroundColor Green
