<#
.SYNOPSIS
    Runs Terraform operations across example deployments, each targeting its own Azure subscription.

.DESCRIPTION
    Looks up Azure subscriptions matching a name pattern and maps each to an example directory.
    Supports init+plan (default), apply, and destroy operations.
    Caches subscription lookups in a local JSON file to avoid repeated Azure CLI calls.

.PARAMETER Action
    The Terraform action to perform: Plan (default), Apply, or Destroy.

.PARAMETER Example
    Optional. Run only a specific example by name (e.g. "default", "asp_linux").

.PARAMETER SubscriptionPrefix
    The subscription name prefix to match. Defaults to "alz-appservice".

.PARAMETER RefreshCache
    Force refresh of the cached subscription mapping.

.EXAMPLE
    .\run-examples.ps1
    # Runs init + plan on all examples

.EXAMPLE
    .\run-examples.ps1 -Action Apply -Example asp_linux_container
    # Runs apply on just the asp_linux_container example

.EXAMPLE
    .\run-examples.ps1 -Action Destroy
    # Runs destroy on all examples
#>

[CmdletBinding()]
param(
    [ValidateSet("Plan", "Apply", "Destroy")]
    [string]$Action = "Plan",

    [string]$Example,

    [string]$SubscriptionPrefix = "alz-appservice",

    [switch]$RefreshCache
)

$ErrorActionPreference = "Stop"
$scriptDir = $PSScriptRoot
$cacheFile = Join-Path $scriptDir ".subscription-cache.json"

# Ordered list of examples mapped to subscription index (1-based)
$exampleMapping = [ordered]@{
    "default"                  = 1
    "asp_linux"                = 2
    "asp_windows"              = 3
    "asp_linux_container"      = 4
    "asp_windows_container"    = 5
    "ase_linux"                = 6
    "ase_windows"              = 7
    "application_gateway"      = 8
    "public_networking"        = 9
    "byo_asp_linux"            = 10
    "managed_instance"         = 11
    "alz_platform_landing_zone" = 12
}

function Get-SubscriptionMap {
    param(
        [string]$Prefix,
        [string]$CachePath,
        [bool]$ForceRefresh
    )

    if (!$ForceRefresh -and (Test-Path $CachePath)) {
        $cached = Get-Content $CachePath -Raw | ConvertFrom-Json -AsHashtable
        if ($cached.Count -gt 0) {
            Write-Host "Using cached subscription mapping from $CachePath" -ForegroundColor DarkGray
            return $cached
        }
    }

    Write-Host "Looking up subscriptions matching '$Prefix-*'..." -ForegroundColor Cyan
    $subs = az account list --all --query "[?starts_with(name, '$Prefix-')].{name:name, id:id}" -o json 2>&1 | ConvertFrom-Json

    if (!$subs -or $subs.Count -eq 0) {
        Write-Error "No subscriptions found matching '$Prefix-*'. Ensure you are logged in and have access."
        return $null
    }

    $map = @{}
    foreach ($sub in $subs) {
        $map[$sub.name] = $sub.id
    }

    $map | ConvertTo-Json | Set-Content $CachePath -Force
    Write-Host "Cached $($map.Count) subscriptions to $CachePath" -ForegroundColor Green
    return $map
}

function Get-SubscriptionForExample {
    param(
        [string]$ExampleName,
        [int]$Index,
        [string]$Prefix,
        [hashtable]$SubMap
    )

    $subName = "{0}-{1:D3}" -f $Prefix, $Index
    if ($SubMap.ContainsKey($subName)) {
        return $SubMap[$subName]
    }

    Write-Warning "No subscription '$subName' found for example '$ExampleName'. Skipping."
    return $null
}

# Main
$subMap = Get-SubscriptionMap -Prefix $SubscriptionPrefix -CachePath $cacheFile -ForceRefresh $RefreshCache.IsPresent

if (!$subMap) { exit 1 }

$examplesToRun = if ($Example) {
    if (!$exampleMapping.Contains($Example)) {
        Write-Error "Unknown example '$Example'. Valid examples: $($exampleMapping.Keys -join ', ')"
        exit 1
    }
    @{ $Example = $exampleMapping[$Example] }
} else {
    $exampleMapping
}

$results = @()

foreach ($entry in $examplesToRun.GetEnumerator()) {
    $exName = $entry.Key
    $exIndex = $entry.Value
    $exDir = Join-Path $scriptDir $exName

    if (!(Test-Path $exDir)) {
        Write-Warning "Example directory '$exDir' not found. Skipping."
        continue
    }

    $subId = Get-SubscriptionForExample -ExampleName $exName -Index $exIndex -Prefix $SubscriptionPrefix -SubMap $subMap
    if (!$subId) { continue }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " $exName ($Action)" -ForegroundColor Cyan
    Write-Host " Subscription: $subId" -ForegroundColor DarkGray
    Write-Host "========================================" -ForegroundColor Cyan

    $env:ARM_SUBSCRIPTION_ID = $subId
    az account set --subscription $subId 2>&1 | Out-Null
    Push-Location $exDir

    try {
        # Init
        Write-Host "  terraform init -upgrade..." -ForegroundColor DarkGray
        $initOutput = terraform init -upgrade 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  INIT FAILED" -ForegroundColor Red
            $results += [PSCustomObject]@{ Example = $exName; Status = "INIT_FAILED" }
            continue
        }

        switch ($Action) {
            "Plan" {
                Write-Host "  terraform plan -out tfplan..." -ForegroundColor Yellow
                terraform plan -out tfplan 2>&1 | ForEach-Object { Write-Host "  $_" }
                $status = if ($LASTEXITCODE -eq 0) { "PLAN_OK" } else { "PLAN_FAILED" }
                $results += [PSCustomObject]@{ Example = $exName; Status = $status }
            }
            "Apply" {
                Write-Host "  terraform apply -auto-approve..." -ForegroundColor Yellow
                terraform apply -auto-approve 2>&1 | ForEach-Object { Write-Host "  $_" }
                $status = if ($LASTEXITCODE -eq 0) { "APPLY_OK" } else { "APPLY_FAILED" }
                $results += [PSCustomObject]@{ Example = $exName; Status = $status }
            }
            "Destroy" {
                Write-Host "  terraform destroy -auto-approve..." -ForegroundColor Red
                terraform destroy -auto-approve 2>&1 | ForEach-Object { Write-Host "  $_" }
                $status = if ($LASTEXITCODE -eq 0) { "DESTROY_OK" } else { "DESTROY_FAILED" }
                $results += [PSCustomObject]@{ Example = $exName; Status = $status }
            }
        }
    }
    finally {
        Pop-Location
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " Summary" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
$results | Format-Table -AutoSize
