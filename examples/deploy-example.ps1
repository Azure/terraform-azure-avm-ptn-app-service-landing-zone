#!/usr/bin/env pwsh
# deploy-example.ps1 - Deploy a single example
# Usage: .\deploy-example.ps1 -Example <name> -SubscriptionId <id>

param(
    [Parameter(Mandatory)][string]$Example,
    [Parameter(Mandatory)][string]$SubscriptionId,
    [switch]$SkipPreScript
)

$ErrorActionPreference = "Continue"
$baseDir = Split-Path $PSScriptRoot -Parent
$exampleDir = Join-Path $baseDir "examples" $Example

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Deploying: $Example" -ForegroundColor Cyan
Write-Host " Subscription: $SubscriptionId" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Set subscription
$env:ARM_SUBSCRIPTION_ID = $SubscriptionId
az account set --subscription $SubscriptionId 2>&1 | Out-Null

# Ensure app.zip exists if pre.ps1 exists
$preScript = Join-Path $exampleDir "pre.ps1"
if (!$SkipPreScript -and (Test-Path $preScript)) {
    $appZip = Join-Path $exampleDir "app.zip"
    if (!(Test-Path $appZip)) {
        $srcZip = Join-Path $baseDir "examples" "default" "app.zip"
        if (Test-Path $srcZip) {
            Copy-Item $srcZip $appZip -Force
            Write-Host "Copied app.zip from default example" -ForegroundColor DarkGray
        } else {
            Write-Host "Running pre.ps1..." -ForegroundColor DarkGray
            Push-Location $exampleDir
            & $preScript
            Pop-Location
        }
    }
}

# Init
Write-Host "terraform init -upgrade..." -ForegroundColor Yellow
terraform -chdir="$exampleDir" init -upgrade 2>&1 | Select-Object -Last 3
if ($LASTEXITCODE -ne 0) {
    Write-Host "INIT FAILED" -ForegroundColor Red
    exit 1
}
Write-Host "Init succeeded" -ForegroundColor Green

# Apply
Write-Host "terraform apply -auto-approve..." -ForegroundColor Yellow
terraform -chdir="$exampleDir" apply -auto-approve 2>&1 | ForEach-Object { Write-Host $_ }
$applyExit = $LASTEXITCODE
if ($applyExit -ne 0) {
    Write-Host "APPLY FAILED (exit: $applyExit)" -ForegroundColor Red
    # Retry once
    Write-Host "Retrying apply..." -ForegroundColor Yellow
    terraform -chdir="$exampleDir" apply -auto-approve 2>&1 | ForEach-Object { Write-Host $_ }
    $applyExit = $LASTEXITCODE
    if ($applyExit -ne 0) {
        Write-Host "APPLY RETRY FAILED (exit: $applyExit)" -ForegroundColor Red
        exit 1
    }
}
Write-Host "Apply succeeded" -ForegroundColor Green

# Plan (idempotency check)
Write-Host "terraform plan (idempotency check)..." -ForegroundColor Yellow
$planOutput = terraform -chdir="$exampleDir" plan -detailed-exitcode 2>&1
$planExit = $LASTEXITCODE
$planOutput | ForEach-Object { Write-Host $_ }
if ($planExit -eq 0) {
    Write-Host "IDEMPOTENCY: PASSED (no changes)" -ForegroundColor Green
} elseif ($planExit -eq 2) {
    Write-Host "IDEMPOTENCY: FAILED (changes detected)" -ForegroundColor Red
} else {
    Write-Host "PLAN FAILED (exit: $planExit)" -ForegroundColor Red
}

Write-Host "========================================" -ForegroundColor Green
Write-Host " $Example deployment complete" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
