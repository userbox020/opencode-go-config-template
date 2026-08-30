param(
  [string]$ProjectPath = (Get-Location).Path,
  [switch]$Force,
  [switch]$NonInteractive,
  [string]$Profile = "",
  [string]$Provider = "opencode-go"
)

$ErrorActionPreference = "Stop"

$ModelSlots = @(
  [ordered]@{
    Key = "primary"
    Title = "Primary and deep reasoning"
    Description = "Planning, fixing, Oracle, architecture, and high-stakes specialist work."
    Default = "opencode-go/glm-5.3-flash"
  },
  [ordered]@{
    Key = "balanced"
    Title = "Fast and balanced work"
    Description = "Routine orchestration, general work, exploration, docs, design, titles, summaries, and compaction."
    Default = "opencode-go/qwen3.8-flash"
  }
)

function Get-OpenCodeCommand {
  foreach ($Candidate in @("opencode.cmd", "opencode")) {
    $Command = Get-Command $Candidate -ErrorAction SilentlyContinue
    if ($Command) {
      return $Command.Source
    }
  }

  return $null
}

function Get-AvailableModels {
  param(
    [string]$OpenCodeCommand,
    [string]$ProviderName
  )

  if (-not $OpenCodeCommand) {
    return @()
  }

  try {
    $Models = @(& $OpenCodeCommand models $ProviderName 2>$null | ForEach-Object { $_.Trim() } | Where-Object { $_ -match "^[^/\s]+/.+" })
    if ($Models.Count -gt 0) {
      return $Models
    }
  } catch {
    return @()
  }

  return @()
}

function Select-Model {
  param(
    [object]$Slot,
    [string[]]$AvailableModels,
    [switch]$SkipPrompt
  )

  $Default = $Slot["Default"]

  if ($SkipPrompt) {
    return $Default
  }

  while ($true) {
    Write-Host ""
    Write-Host "== $($Slot["Title"]) =="
    Write-Host $Slot["Description"]
    Write-Host "Default: $Default"

    if ($AvailableModels.Count -gt 0) {
      Write-Host ""
      Write-Host "Available models:"
      for ($Index = 0; $Index -lt $AvailableModels.Count; $Index++) {
        $Marker = ""
        if ($AvailableModels[$Index] -eq $Default) {
          $Marker = " (default)"
        }
        Write-Host "  $($Index + 1). $($AvailableModels[$Index])$Marker"
      }
    } else {
      Write-Host ""
      Write-Host "No models were returned by opencode. You can still type a full provider/model id."
    }

    $Answer = Read-Host "Choose model number or provider/model for '$($Slot["Key"])' [Enter = default]"
    $Answer = $Answer.Trim()

    if ($Answer -eq "") {
      return $Default
    }

    if ($Answer -match "^\d+$") {
      $SelectedIndex = [int]$Answer - 1
      if ($SelectedIndex -ge 0 -and $SelectedIndex -lt $AvailableModels.Count) {
        return $AvailableModels[$SelectedIndex]
      }
    }

    if ($Answer -match "^[^\s/]+/.+$") {
      return $Answer
    }

    Write-Host "Invalid selection. Use a listed number, press Enter for default, or type provider/model."
  }
}

function ConvertTo-PrettyJsonFile {
  param(
    [object]$InputObject,
    [string]$Path
  )

  $Json = $InputObject | ConvertTo-Json -Depth 100
  $Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, ($Json + [Environment]::NewLine), $Utf8NoBom)
}

function Apply-CuratedProfile {
  param(
    [string]$DestinationPath,
    [string]$ProfileName
  )

  if ($ProfileName -eq "balanced") {
    return
  }

  $OpenCodeConfigPath = Join-Path -Path $DestinationPath -ChildPath "opencode.jsonc"
  $SlimConfigPath = Join-Path -Path $DestinationPath -ChildPath "oh-my-opencode-slim.jsonc"
  $OpenCodeConfig = Get-Content -LiteralPath $OpenCodeConfigPath -Raw | ConvertFrom-Json

  $OpenCodeConfig.model = "opencode-go/qwen3.8-max"
  $OpenCodeConfig.small_model = "opencode-go/qwen3.8-flash"
  $OpenCodeConfig.agent.build.model = "opencode-go/kimi-k2.7-code"
  $OpenCodeConfig.agent.build.PSObject.Properties.Remove("variant")
  $OpenCodeConfig.agent.plan.model = "opencode-go/glm-5.3"
  $OpenCodeConfig.agent.plan.variant = "max"
  $OpenCodeConfig.agent.general.model = "opencode-go/qwen3.8-max"
  $OpenCodeConfig.agent.general.variant = "medium"
  $OpenCodeConfig.agent.explore.model = "opencode-go/qwen3.8-flash"
  $OpenCodeConfig.agent.explore.variant = "medium"
  foreach ($AgentName in @("title", "summary", "compaction")) {
    $OpenCodeConfig.agent.$AgentName.model = "opencode-go/qwen3.8-flash"
    $OpenCodeConfig.agent.$AgentName.variant = "low"
  }
  ConvertTo-PrettyJsonFile -InputObject $OpenCodeConfig -Path $OpenCodeConfigPath

  $SlimConfig = Get-Content -LiteralPath $SlimConfigPath -Raw | ConvertFrom-Json
  $SlimConfig.preset = "quality"
  ConvertTo-PrettyJsonFile -InputObject $SlimConfig -Path $SlimConfigPath
}

function Apply-ModelChoices {
  param(
    [string]$DestinationPath,
    [hashtable]$Models,
    [ValidateSet("balanced", "quality")]
    [string]$ProfileName
  )

  $OpenCodeConfigPath = Join-Path -Path $DestinationPath -ChildPath "opencode.jsonc"
  $SlimConfigPath = Join-Path -Path $DestinationPath -ChildPath "oh-my-opencode-slim.jsonc"

  $OpenCodeConfig = Get-Content -LiteralPath $OpenCodeConfigPath -Raw | ConvertFrom-Json
  $Primary = $Models["primary"]
  $Balanced = $Models["balanced"]
  $CustomProviders = @($Primary, $Balanced) | ForEach-Object { ($_ -split "/", 2)[0] } | Select-Object -Unique

  $OpenCodeConfig.enabled_providers = @("opencode-go") + @($CustomProviders | Where-Object { $_ -ne "opencode-go" })
  $OpenCodeConfig.model = $Balanced
  $OpenCodeConfig.small_model = $Balanced
  $OpenCodeConfig.agent.build.model = $Primary
  $OpenCodeConfig.agent.build.PSObject.Properties.Remove("variant")
  $OpenCodeConfig.agent.plan.model = $Primary
  $OpenCodeConfig.agent.plan.PSObject.Properties.Remove("variant")
  $OpenCodeConfig.agent.general.model = $Balanced
  $OpenCodeConfig.agent.general.PSObject.Properties.Remove("variant")
  $OpenCodeConfig.agent.explore.model = $Balanced
  $OpenCodeConfig.agent.explore.PSObject.Properties.Remove("variant")
  $OpenCodeConfig.agent.title.model = $Balanced
  $OpenCodeConfig.agent.title.PSObject.Properties.Remove("variant")
  $OpenCodeConfig.agent.summary.model = $Balanced
  $OpenCodeConfig.agent.summary.PSObject.Properties.Remove("variant")
  $OpenCodeConfig.agent.compaction.model = $Balanced
  $OpenCodeConfig.agent.compaction.PSObject.Properties.Remove("variant")
  ConvertTo-PrettyJsonFile -InputObject $OpenCodeConfig -Path $OpenCodeConfigPath

  $SlimConfig = Get-Content -LiteralPath $SlimConfigPath -Raw | ConvertFrom-Json
  $SlimConfig.preset = $ProfileName
  foreach ($PresetName in @("balanced", "quality")) {
    $Preset = $SlimConfig.presets.$PresetName
    $Preset.orchestrator.model = @(
      [pscustomobject]@{ id = $Balanced },
      [pscustomobject]@{ id = $Primary }
    )
    $Preset.oracle.model = @(
      [pscustomobject]@{ id = $Primary },
      [pscustomobject]@{ id = $Balanced }
    )
    $Preset.council.model = @(
      [pscustomobject]@{ id = $Primary },
      [pscustomobject]@{ id = $Balanced }
    )
    $Preset.explorer.model = @(
      [pscustomobject]@{ id = $Balanced },
      [pscustomobject]@{ id = $Primary }
    )
    $Preset.librarian.model = @(
      [pscustomobject]@{ id = $Balanced },
      [pscustomobject]@{ id = $Primary }
    )
    $Preset.fixer.model = @(
      [pscustomobject]@{ id = $Primary },
      [pscustomobject]@{ id = $Balanced }
    )
    $Preset.designer.model = @(
      [pscustomobject]@{ id = $Balanced },
      [pscustomobject]@{ id = $Primary }
    )
  }

  $SlimConfig.agents."code-reviewer".model = $Primary
  $SlimConfig.agents."code-reviewer".PSObject.Properties.Remove("variant")
  $SlimConfig.agents."repo-architect".model = $Primary
  $SlimConfig.agents."repo-architect".PSObject.Properties.Remove("variant")
  $SlimConfig.agents."test-writer".model = $Balanced
  $SlimConfig.agents."test-writer".PSObject.Properties.Remove("variant")
  $SlimConfig.agents."security-reviewer".model = $Primary
  $SlimConfig.agents."security-reviewer".PSObject.Properties.Remove("variant")

  $CouncilPreset = $SlimConfig.council.presets."generic-review-board"
  $CouncilPreset."correctness-review".model = $Primary
  $CouncilPreset."correctness-review".PSObject.Properties.Remove("variant")
  $CouncilPreset."architecture-review".model = $Primary
  $CouncilPreset."architecture-review".PSObject.Properties.Remove("variant")
  $CouncilPreset."security-review".model = $Balanced
  $CouncilPreset."security-review".PSObject.Properties.Remove("variant")
  ConvertTo-PrettyJsonFile -InputObject $SlimConfig -Path $SlimConfigPath
}

$SelectedProfile = $Profile.Trim().ToLowerInvariant()
if ($SelectedProfile -ne "" -and $SelectedProfile -notin @("balanced", "quality")) {
  throw "Profile must be 'balanced' or 'quality'."
}

if ($SelectedProfile -eq "") {
  if ($NonInteractive) {
    $SelectedProfile = "balanced"
  } else {
    while ($true) {
      $ProfileAnswer = (Read-Host "Choose curated profile: 1 = balanced, 2 = quality [Enter = balanced]").Trim().ToLowerInvariant()
      if ($ProfileAnswer -in @("", "1", "balanced")) {
        $SelectedProfile = "balanced"
        break
      }
      if ($ProfileAnswer -in @("2", "quality")) {
        $SelectedProfile = "quality"
        break
      }
      Write-Host "Invalid profile. Choose 1/balanced or 2/quality."
    }
  }
}

if ($env:OH_MY_OPENCODE_SLIM_PRESET -and $env:OH_MY_OPENCODE_SLIM_PRESET.Trim().ToLowerInvariant() -ne $SelectedProfile) {
  Write-Warning "OH_MY_OPENCODE_SLIM_PRESET overrides Slim at runtime. Set it to '$SelectedProfile' or unset it to use the installed profile."
}

if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
  throw "ProjectPath does not exist or is not a directory: $ProjectPath"
}

$RepoRoot = Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath "..")
$Source = Join-Path -Path $RepoRoot -ChildPath "template\.opencode"
$Destination = Join-Path -Path $ProjectPath -ChildPath ".opencode"

if (-not (Test-Path -LiteralPath $Source -PathType Container)) {
  throw "Template source not found: $Source"
}

if ((Test-Path -LiteralPath $Destination) -and -not $Force) {
  throw "Target already has .opencode. Re-run with -Force to merge and overwrite matching template files."
}

if (-not (Test-Path -LiteralPath $Destination)) {
  New-Item -ItemType Directory -Path $Destination | Out-Null
}

Get-ChildItem -LiteralPath $Source -Force | Copy-Item -Destination $Destination -Recurse -Force
Apply-CuratedProfile -DestinationPath $Destination -ProfileName $SelectedProfile

$CustomizeRouting = $false

if (-not $NonInteractive) {
  ""
  "Interactive model routing"
  "Provider queried: $Provider"
  $CustomizeAnswer = Read-Host "Replace the '$SelectedProfile' profile with two selected models? [y/N]"
  if ($CustomizeAnswer.Trim() -match "^(y|yes)$") {
    $CustomizeRouting = $true
  }
}

$SelectedModels = @{}
if ($CustomizeRouting) {
  $OpenCodeCommand = Get-OpenCodeCommand
  $AvailableModels = Get-AvailableModels -OpenCodeCommand $OpenCodeCommand -ProviderName $Provider
  if ($AvailableModels.Count -gt 0) {
    "Found $($AvailableModels.Count) model(s) via opencode models $Provider."
  } else {
    "No model list was available from opencode models $Provider. You can still type full provider/model IDs."
  }

  foreach ($Slot in $ModelSlots) {
    $SelectedModels[$Slot["Key"]] = Select-Model -Slot $Slot -AvailableModels $AvailableModels
  }

  Apply-ModelChoices -DestinationPath $Destination -Models $SelectedModels -ProfileName $SelectedProfile
}

"Installed OpenCode Go generic project config to $Destination"
""
"Selected model routing:"
if ($CustomizeRouting) {
  foreach ($Slot in $ModelSlots) {
    "  $($Slot["Key"]): $($SelectedModels[$Slot["Key"]])"
  }
} else {
  "  $SelectedProfile curated profile"
}
""
"Restart OpenCode in the target project so it loads the new config."
