#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

$sampleCommit = "19b1e5f8843ca8c36c41aa701823a4f18ee78c53"
$outputPath = Join-Path $PWD.Path "app.zip"
$stagingPath = Join-Path ([IO.Path]::GetTempPath()) "avm-sample-app-$([guid]::NewGuid().ToString('N'))"

$null = New-Item -ItemType Directory -Path $stagingPath
try {
  $sourcePath = Join-Path $stagingPath "source"
  Write-Host "Downloading the .NET 10 sample ASP.NET app..."
  git init --quiet $sourcePath
  git -C $sourcePath remote add origin https://github.com/dotnet/dotnet-docker.git
  git -C $sourcePath sparse-checkout set samples/aspnetapp/aspnetapp
  git -C $sourcePath fetch --quiet --depth 1 --filter=blob:none origin $sampleCommit
  git -C $sourcePath checkout --quiet --detach FETCH_HEAD

  $projectPath = Join-Path $sourcePath "samples/aspnetapp/aspnetapp"
  if (-not (Test-Path -LiteralPath (Join-Path $projectPath "aspnetapp.csproj") -PathType Leaf)) {
    throw "The pinned sample commit $sampleCommit does not contain aspnetapp.csproj."
  }

  Write-Host "Creating app.zip..."
  $archivePath = Join-Path $stagingPath "app.zip"
  Compress-Archive -Path (Join-Path $projectPath "*") -DestinationPath $archivePath
  Move-Item -LiteralPath $archivePath -Destination $outputPath -Force
} finally {
  Remove-Item -LiteralPath $stagingPath -Recurse -Force
}

Write-Host "app.zip created successfully."
