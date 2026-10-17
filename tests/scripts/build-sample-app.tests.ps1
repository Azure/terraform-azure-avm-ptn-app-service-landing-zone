[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [string] $WorkingDirectory
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false
Import-Module Avm.Authoring -ErrorAction Stop

$hookPath = Join-Path $PSScriptRoot "../../examples/default/pre.ps1"
$examplesPath = Join-Path $PSScriptRoot "../../examples"
$contracts = @(
  foreach ($example in Get-ChildItem -LiteralPath $examplesPath -Directory) {
    if (-not (Test-Path -LiteralPath (Join-Path $example.FullName "pre.ps1"))) { continue }
    $text = [IO.File]::ReadAllText((Join-Path $example.FullName "main.tf"))
    $blob = [regex]::Match($text, '(?ms)^resource\s+"azurerm_storage_blob"\s+"zip_deploy"\s*\{\r?\n(?<body>.*?)^\}')
    $checksum = [regex]::Match($blob.Groups["body"].Value, '(?m)^\s*content_md5\s*=\s*(?<value>[^\r\n]+)')
    $precondition = [regex]::Match($blob.Groups["body"].Value, '(?ms)precondition\s*\{\s*condition\s*=\s*(?<condition>[^\r\n]+)\r?\n\s*error_message\s*=\s*(?<message>[^\r\n]+)\r?\n\s*\}')
    if (-not $blob.Success -or -not $checksum.Success -or -not $precondition.Success) {
      throw "Example '$($example.Name)' must guard its checksum and explicitly reject a missing archive at plan time."
    }
    $expression = $checksum.Groups["value"].Value.Trim()
    $condition = $precondition.Groups["condition"].Value.Trim()
    $message = $precondition.Groups["message"].Value.Trim()
    if ($expression -cne 'fileexists("${path.module}/app.zip") ? filemd5("${path.module}/app.zip") : null' -or
        $condition -cne 'fileexists("${path.module}/app.zip")' -or
        $message -notmatch '^"The sample application archive is missing\..*pre\.ps1.*"$') {
      throw "Example '$($example.Name)' changed the archive lifecycle contract."
    }
    [pscustomobject]@{
      Example    = $example.Name
      Checksum   = $expression
      Condition  = $condition
      Message    = $message
    }
  }
)
if ($contracts.Count -eq 0) { throw "No zip-deployment examples were checked." }
foreach ($contract in $contracts) {
  if ($contract.Message -cne $contracts[0].Message) {
    throw "All zip-deployment examples must provide the same actionable missing-archive diagnostic."
  }
}

$testPath = Join-Path $WorkingDirectory "sample-app-test-$([guid]::NewGuid().ToString('N'))"
$originalTemp = $env:TEMP
$originalTmp = $env:TMP
$originalConfigCount = $env:GIT_CONFIG_COUNT
$configIndex = if ($originalConfigCount) { [int]$originalConfigCount } else { 0 }
$configKey = "GIT_CONFIG_KEY_$configIndex"
$configValue = "GIT_CONFIG_VALUE_$configIndex"
$originalConfigKey = [Environment]::GetEnvironmentVariable($configKey, "Process")
$originalConfigValue = [Environment]::GetEnvironmentVariable($configValue, "Process")

$null = New-Item -ItemType Directory -Path $testPath
Push-Location $testPath
try {
  $env:TEMP = Join-Path $testPath "temp"
  $env:TMP = $env:TEMP
  $null = New-Item -ItemType Directory -Path $env:TEMP
  $null = New-Item -ItemType Directory -Path "dotnet-docker-temp"
  Set-Content -LiteralPath "dotnet-docker-temp/keep.txt" -Value "Existing checkout"

  $encoding = [Text.UTF8Encoding]::new($false)
  $testDirectory = Join-Path $testPath "tests/unit"
  $exampleDirectory = Join-Path $testPath "examples/default"
  $null = New-Item -ItemType Directory -Path $testDirectory, $exampleDirectory
  $contractTestPath = Join-Path $testDirectory "archive.tftest.hcl"
  # Evaluate the authored expressions without substituting an Azure resource or a dummy archive.
  $fixture = @'
terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    terraform = {
      source = "terraform.io/builtin/terraform"
    }
  }
}

resource "terraform_data" "archive" {
  input = __CHECKSUM__

  lifecycle {
    precondition {
      condition     = __CONDITION__
      error_message = __MESSAGE__
    }
  }
}
'@
  $fixture = $fixture.Replace("__CHECKSUM__", $contracts[0].Checksum).
    Replace("__CONDITION__", $contracts[0].Condition).
    Replace("__MESSAGE__", $contracts[0].Message)
  [IO.File]::WriteAllText((Join-Path $testPath "main.tf"), ($fixture -replace "`r`n", "`n") + "`n", $encoding)
  [IO.File]::WriteAllText((Join-Path $exampleDirectory "main.tf"), "module `"archive`" {`n  source = `"../..`"`n}`n", $encoding)
  [IO.File]::WriteAllText($contractTestPath, "mock_provider `"terraform`" {}`n`nrun `"missing_archive_is_rejected`" {`n  command = plan`n  providers = { terraform = terraform }`n  expect_failures = [terraform_data.archive]`n}`n", $encoding)
  $validation = Invoke-AvmTest -Path $testPath -Ecosystem terraform
  if ($validation.Status -ne "pass") { throw "Validation must succeed before the archive is built." }
  $missingArchive = Invoke-AvmTestUnit -Path $testPath -Ecosystem terraform
  if ($missingArchive.Status -ne "pass" -or $missingArchive.RunsPassed -ne 1 -or $missingArchive.RunsFailed -ne 0) {
    throw "Planning must reject a missing archive through the authored precondition."
  }

  foreach ($attempt in 1..2) {
    & pwsh -NoProfile -NonInteractive -File $hookPath
    if ($LASTEXITCODE -ne 0) { throw "Sample hook failed on attempt $attempt." }

    $archive = [IO.Compression.ZipFile]::OpenRead((Join-Path $testPath "app.zip"))
    try {
      $project = $archive.GetEntry("aspnetapp.csproj")
      if ($null -eq $project -or $null -eq $archive.GetEntry("Program.cs") -or
          $null -eq $archive.GetEntry("Pages/Index.cshtml")) {
        throw "The archive must contain the genuine ASP.NET project at its root."
      }
      $reader = [IO.StreamReader]::new($project.Open())
      try {
        if ($reader.ReadToEnd() -notmatch '<TargetFramework>net10\.0</TargetFramework>') {
          throw "The sample must match the examples' .NET 10 runtime."
        }
      } finally {
        $reader.Dispose()
      }
    } finally {
      $archive.Dispose()
    }
    if (-not (Test-Path -LiteralPath "dotnet-docker-temp/keep.txt")) {
      throw "An existing checkout was removed."
    }
    if (@(Get-ChildItem -LiteralPath $env:TEMP).Count -ne 0) {
      throw "The hook left temporary files behind."
    }

    $expectedMd5 = (Get-FileHash -LiteralPath "app.zip" -Algorithm MD5).Hash.ToLowerInvariant()
    $checksumTest = @'
mock_provider "terraform" {}

run "archive_checksum_matches_bytes" {
  command = plan
  providers = { terraform = terraform }

  assert {
    condition     = terraform_data.archive.input == "__MD5__"
    error_message = "The upload checksum must match the genuine packaged bytes."
  }
}
'@
    [IO.File]::WriteAllText($contractTestPath, (($checksumTest.Replace("__MD5__", $expectedMd5)) -replace "`r`n", "`n") + "`n", $encoding)
    $packagedArchive = Invoke-AvmTestUnit -Path $testPath -Ecosystem terraform
    if ($packagedArchive.Status -ne "pass" -or $packagedArchive.RunsPassed -ne 1 -or $packagedArchive.RunsFailed -ne 0) {
      throw "The authored checksum did not match the genuine archive on attempt $attempt."
    }
  }

  $archiveHash = (Get-FileHash -LiteralPath "app.zip").Hash
  [Environment]::SetEnvironmentVariable($configKey, "url.$(Join-Path $testPath 'missing-repository').insteadOf", "Process")
  [Environment]::SetEnvironmentVariable($configValue, "https://github.com/dotnet/dotnet-docker.git", "Process")
  $env:GIT_CONFIG_COUNT = [string]($configIndex + 1)
  & pwsh -NoProfile -NonInteractive -File $hookPath
  if ($LASTEXITCODE -eq 0) { throw "A Git fetch failure must fail the hook." }
  if ((Get-FileHash -LiteralPath "app.zip").Hash -ne $archiveHash) {
    throw "A failed fetch replaced the existing deployment archive."
  }
  if (@(Get-ChildItem -LiteralPath $env:TEMP).Count -ne 0) {
    throw "A failed fetch left temporary files behind."
  }
  Write-Host "Passed: $($contracts.Count) authored archive contracts, artifact-free validation, explicit missing-archive plan failure, genuine MD5 values, .NET 10, repeat packaging, existing checkout preservation, and fetch failure cleanup."
} finally {
  $env:TEMP = $originalTemp
  $env:TMP = $originalTmp
  [Environment]::SetEnvironmentVariable("GIT_CONFIG_COUNT", $(if ($null -eq $originalConfigCount) { [NullString]::Value } else { $originalConfigCount }), "Process")
  [Environment]::SetEnvironmentVariable($configKey, $(if ($null -eq $originalConfigKey) { [NullString]::Value } else { $originalConfigKey }), "Process")
  [Environment]::SetEnvironmentVariable($configValue, $(if ($null -eq $originalConfigValue) { [NullString]::Value } else { $originalConfigValue }), "Process")
  Pop-Location
  Remove-Item -LiteralPath $testPath -Recurse -Force
}
