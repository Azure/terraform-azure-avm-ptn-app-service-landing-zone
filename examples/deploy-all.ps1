#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Deploy examples sequentially with retry logic and idempotency checks.
.PARAMETER Examples
    Comma-separated list of examples to deploy. Defaults to all.
.PARAMETER SkipCompleted
    Skip examples that already have state files with resources.
.PARAMETER MaxRetries
    Number of apply retries for transient errors. Default 3.
.PARAMETER PlanOnly
    Only run plan (idempotency check) on examples that have state.
#>
[CmdletBinding()]
param(
    [string]$Examples,
    [switch]$SkipCompleted,
    [int]$MaxRetries = 3,
    [switch]$PlanOnly
)

$ErrorActionPreference = "Continue"
$baseDir = $PSScriptRoot

# Subscription mapping (must match run-examples.ps1)
$subMap = [ordered]@{
    "default"                   = "7db7b507-bd99-47c1-bc41-80dbe513c33e"
    "asp_linux"                 = "924d0c55-536c-4389-9bc2-675446f2db04"
    "asp_windows"               = "9c9f04d2-54ca-48cc-9b75-51aefe712b1a"
    "asp_linux_container"       = "7730e89d-4751-407c-a9cb-f052660843a4"
    "asp_windows_container"     = "b9e9da09-d8bf-4127-b906-5862ee001490"
    "ase_linux"                 = "edb87fea-0ac6-436b-b163-f7f00ace7a9c"
    "ase_windows"               = "4056fff3-5233-4064-88e7-281b6c9cdba3"
    "application_gateway"       = "10bddebc-6061-4265-83c8-59d442da6500"
    "public_networking"         = "1cbaa667-e245-42f4-9c93-153b62d10eb0"
    "byo_asp_linux"             = "ef30e1da-efb0-44e4-8196-a5a9eb8f7235"
    "managed_instance"          = "ef186ff7-fedb-4d8e-a73f-7f2e320d5bc4"
    "alz_platform_landing_zone" = "4816799f-ec19-46e8-8b48-8f94814f92f4"
}

# Filter examples
$toRun = if ($Examples) {
    $Examples -split ',' | ForEach-Object { $_.Trim() }
} else {
    $subMap.Keys
}

$results = @()

foreach ($ex in $toRun) {
    if (-not $subMap.Contains($ex)) {
        Write-Host "UNKNOWN: $ex" -ForegroundColor Red
        continue
    }

    $exDir = Join-Path $baseDir $ex
    $subId = $subMap[$ex]
    $stateFile = Join-Path $exDir "terraform.tfstate"

    Write-Host ""
    Write-Host ("=" * 60) -ForegroundColor Cyan
    Write-Host " $ex" -ForegroundColor Cyan
    Write-Host " Sub: $subId" -ForegroundColor DarkGray
    Write-Host ("=" * 60) -ForegroundColor Cyan

    $env:ARM_SUBSCRIPTION_ID = $subId

    # Check if already deployed
    $hasState = Test-Path $stateFile
    if ($hasState -and $SkipCompleted) {
        Write-Host "  SKIPPED (has state)" -ForegroundColor DarkGray
        $results += [PSCustomObject]@{ Example=$ex; Status="SKIPPED" }
        continue
    }

    # Plan-only mode
    if ($PlanOnly) {
        if (-not $hasState) {
            Write-Host "  NO STATE - skipping plan" -ForegroundColor DarkGray
            $results += [PSCustomObject]@{ Example=$ex; Status="NO_STATE" }
            continue
        }
        Write-Host "  terraform plan -detailed-exitcode..." -ForegroundColor Yellow
        terraform -chdir="$exDir" plan -detailed-exitcode 2>&1 | ForEach-Object { Write-Host "  $_" }
        $planExit = $LASTEXITCODE
        if ($planExit -eq 0) {
            Write-Host "  IDEMPOTENT" -ForegroundColor Green
            $results += [PSCustomObject]@{ Example=$ex; Status="IDEMPOTENT" }
        } elseif ($planExit -eq 2) {
            Write-Host "  CHANGES DETECTED" -ForegroundColor Yellow
            $results += [PSCustomObject]@{ Example=$ex; Status="CHANGES" }
        } else {
            Write-Host "  PLAN FAILED" -ForegroundColor Red
            $results += [PSCustomObject]@{ Example=$ex; Status="PLAN_FAILED" }
        }
        continue
    }

    # Ensure app.zip exists for non-container examples
    $preScript = Join-Path $exDir "pre.ps1"
    if (Test-Path $preScript) {
        $appZip = Join-Path $exDir "app.zip"
        if (-not (Test-Path $appZip)) {
            $srcZip = Join-Path $baseDir "default" "app.zip"
            if (Test-Path $srcZip) {
                Copy-Item $srcZip $appZip -Force
                Write-Host "  Copied app.zip" -ForegroundColor DarkGray
            }
        }
    }

    # Init (clean first to pick up module changes)
    Write-Host "  terraform init -upgrade..." -ForegroundColor DarkGray
    Remove-Item (Join-Path $exDir ".terraform") -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item (Join-Path $exDir ".terraform.lock.hcl") -Force -ErrorAction SilentlyContinue
    terraform -chdir="$exDir" init -upgrade 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  INIT FAILED" -ForegroundColor Red
        $results += [PSCustomObject]@{ Example=$ex; Status="INIT_FAILED" }
        continue
    }

    # Apply with retries
    $applied = $false
    for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
        Write-Host "  terraform apply (attempt $attempt/$MaxRetries)..." -ForegroundColor Yellow
        terraform -chdir="$exDir" apply -auto-approve 2>&1 | ForEach-Object { Write-Host "  $_" }
        if ($LASTEXITCODE -eq 0) {
            $applied = $true
            break
        }
        Write-Host "  Apply failed, retrying..." -ForegroundColor DarkYellow
        Start-Sleep 10
    }

    if (-not $applied) {
        Write-Host "  APPLY FAILED after $MaxRetries attempts" -ForegroundColor Red
        $results += [PSCustomObject]@{ Example=$ex; Status="APPLY_FAILED" }
        continue
    }

    Write-Host "  Apply succeeded" -ForegroundColor Green

    # Idempotency check
    Write-Host "  terraform plan (idempotency check)..." -ForegroundColor DarkGray
    terraform -chdir="$exDir" plan -detailed-exitcode 2>&1 | Out-Null
    $planExit = $LASTEXITCODE
    if ($planExit -eq 0) {
        Write-Host "  IDEMPOTENT" -ForegroundColor Green
        $results += [PSCustomObject]@{ Example=$ex; Status="DEPLOYED_IDEMPOTENT" }
    } elseif ($planExit -eq 2) {
        Write-Host "  CHANGES DETECTED (not idempotent)" -ForegroundColor Yellow
        $results += [PSCustomObject]@{ Example=$ex; Status="DEPLOYED_NOT_IDEMPOTENT" }
    } else {
        Write-Host "  PLAN ERROR" -ForegroundColor Red
        $results += [PSCustomObject]@{ Example=$ex; Status="DEPLOYED_PLAN_ERROR" }
    }
}

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor Green
Write-Host " Summary" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Green
$results | Format-Table -AutoSize
