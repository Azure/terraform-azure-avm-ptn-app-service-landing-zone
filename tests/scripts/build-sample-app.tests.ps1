[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [string] $WorkingDirectory
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false
$hookPath = Join-Path $PSScriptRoot "../../examples/default/pre.ps1"
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
  Write-Host "Passed: archive contents, .NET 10, repeat execution, existing checkout preservation, and fetch failure cleanup."
} finally {
  $env:TEMP = $originalTemp
  $env:TMP = $originalTmp
  $env:GIT_CONFIG_COUNT = $originalConfigCount
  [Environment]::SetEnvironmentVariable($configKey, $originalConfigKey, "Process")
  [Environment]::SetEnvironmentVariable($configValue, $originalConfigValue, "Process")
  Pop-Location
  Remove-Item -LiteralPath $testPath -Recurse -Force
}
