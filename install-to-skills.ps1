[CmdletBinding()]
param(
  [ValidateSet("all", "codex", "claude", "agents", "copilot")]
  [string[]] $Targets = @("all"),

  [string[]] $ExtraSkillRoots = @(),

  [switch] $DryRun,

  [switch] $Yes,

  [switch] $Uninstall
)

$ErrorActionPreference = "Stop"

function Join-UserPath {
  param([string] $ChildPath)
  return (Join-Path -Path $HOME -ChildPath $ChildPath)
}

function Get-KnownSkillRoots {
  $roots = [ordered]@{
    codex  = if ($env:CODEX_HOME) { Join-Path $env:CODEX_HOME "skills" } else { Join-UserPath ".codex/skills" }
    claude = if ($env:CLAUDE_HOME) { Join-Path $env:CLAUDE_HOME "skills" } else { Join-UserPath ".claude/skills" }
    agents = if ($env:AGENTS_HOME) { Join-Path $env:AGENTS_HOME "skills" } else { Join-UserPath ".agents/skills" }
    copilot = if ($env:COPILOT_HOME) { Join-Path $env:COPILOT_HOME "skills" } else { Join-UserPath ".copilot/skills" }
  }

  return $roots
}

function Test-IncludedPath {
  param(
    [string] $RelativePath
  )

  $normalized = $RelativePath -replace "\\", "/"
  $included = @(
    "SKILL.md",
    "agents",
    "agents/*",
    "assets",
    "assets/*",
    "references",
    "references/*",
    "scripts",
    "scripts/*"
  )

  foreach ($pattern in $included) {
    if ($normalized -like $pattern) {
      return $true
    }
  }

  return $false
}

function Copy-SkillDirectory {
  param(
    [string] $Source,
    [string] $Destination
  )

  $sourceRoot = (Resolve-Path -LiteralPath $Source).Path
  New-Item -ItemType Directory -Path $Destination -Force | Out-Null

  Get-ChildItem -LiteralPath $sourceRoot -Force -Recurse | ForEach-Object {
    $relative = $_.FullName.Substring($sourceRoot.Length).TrimStart("\", "/")

    if ([string]::IsNullOrWhiteSpace($relative) -or -not (Test-IncludedPath $relative)) {
      return
    }

    $target = Join-Path $Destination $relative

    if ($_.PSIsContainer) {
      New-Item -ItemType Directory -Path $target -Force | Out-Null
    } else {
      $parent = Split-Path -Parent $target
      New-Item -ItemType Directory -Path $parent -Force | Out-Null
      Copy-Item -LiteralPath $_.FullName -Destination $target -Force
    }
  }
}

function Install-OneTarget {
  param(
    [string] $Name,
    [string] $SkillRoot,
    [string] $Source,
    [string] $SkillName,
    [switch] $CreateRoot
  )

  $destination = Join-Path $SkillRoot $SkillName

  if (-not (Test-Path -LiteralPath $SkillRoot)) {
    if ($CreateRoot) {
      if ($DryRun) {
        Write-Host "[dry-run] $Name root would be created: $SkillRoot"
      } else {
        New-Item -ItemType Directory -Path $SkillRoot -Force | Out-Null
      }
    } else {
      Write-Host "Skipped ${Name}: skill root not found: $SkillRoot"
      return
    }
  }

  if ($DryRun) {
    Write-Host "[dry-run] $Name -> $destination"
    if (Test-Path -LiteralPath $destination) {
      Write-Host "[dry-run] existing skill would prompt for replacement: $destination"
    }
    return
  }

  if (Test-Path -LiteralPath $destination) {
    if ($Yes) {
      Remove-Item -LiteralPath $destination -Recurse -Force
      Write-Host "Replaced existing $Name skill: $destination"
    } else {
      $answer = Read-Host "Existing $Name skill found at $destination. Replace? [y/N]"
      if ($answer -notin @("y", "Y")) {
        Write-Host "Skipped ${Name}: existing skill was kept."
        return
      }

      Remove-Item -LiteralPath $destination -Recurse -Force
      Write-Host "Replaced existing $Name skill: $destination"
    }
  }

  Copy-SkillDirectory -Source $Source -Destination $destination
  Write-Host "Installed $Name skill: $destination"
}

function Uninstall-OneTarget {
  param(
    [string] $Name,
    [string] $SkillRoot,
    [string] $SkillName
  )

  $destination = Join-Path $SkillRoot $SkillName

  if (-not (Test-Path -LiteralPath $SkillRoot)) {
    Write-Host "Skipped ${Name}: skill root not found: $SkillRoot"
    return
  }

  if (-not (Test-Path -LiteralPath $destination)) {
    Write-Host "Skipped ${Name}: skill not installed: $destination"
    return
  }

  if ($DryRun) {
    Write-Host "[dry-run] $Name would be removed: $destination"
    return
  }

  Remove-Item -LiteralPath $destination -Recurse -Force
  Write-Host "Uninstalled $Name skill: $destination"
}

$source = Split-Path -Parent $PSCommandPath
$skillName = Split-Path -Leaf $source
$skillFile = Join-Path $source "SKILL.md"

if (-not (Test-Path -LiteralPath $skillFile)) {
  throw "SKILL.md was not found. Run this script from inside a skill repository."
}

$knownRoots = Get-KnownSkillRoots
$requestedTargets = New-Object System.Collections.Generic.List[string]

if ($Targets -contains "all") {
  foreach ($key in $knownRoots.Keys) {
    $requestedTargets.Add($key)
  }
} else {
  foreach ($target in $Targets) {
    $requestedTargets.Add($target)
  }
}

Write-Host "Source skill: $source"
Write-Host "Skill name:   $skillName"
Write-Host "Mode:         $(if ($Uninstall) { 'uninstall' } else { 'install' })"

foreach ($target in $requestedTargets) {
  if ($Uninstall) {
    Uninstall-OneTarget -Name $target -SkillRoot $knownRoots[$target] -SkillName $skillName
  } else {
    Install-OneTarget -Name $target -SkillRoot $knownRoots[$target] -Source $source -SkillName $skillName
  }
}

foreach ($extraRoot in $ExtraSkillRoots) {
  if ([string]::IsNullOrWhiteSpace($extraRoot)) {
    continue
  }

  $expandedRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($extraRoot)
  if ($Uninstall) {
    Uninstall-OneTarget -Name "custom" -SkillRoot $expandedRoot -SkillName $skillName
  } else {
    Install-OneTarget -Name "custom" -SkillRoot $expandedRoot -Source $source -SkillName $skillName -CreateRoot
  }
}

Write-Host "Done."
