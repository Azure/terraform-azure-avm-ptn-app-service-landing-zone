#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

# Download the sample ASP.NET app source from https://github.com/dotnet/dotnet-docker
# and create app.zip for zip deploy. App Service builds the app during deployment
# via the SCM_DO_BUILD_DURING_DEPLOYMENT app setting (Oryx build system).
# This script is called by each example's pre.ps1 and is run automatically by the
# AVM test framework before terraform apply.

# Remove app.zip if it already exists to ensure a fresh build
if (Test-Path "app.zip") {
  Write-Host "Removing existing app.zip..."
  Remove-Item -Force "app.zip"
}

# Clone only the sample ASP.NET app (sparse checkout for minimal download)
Write-Host "Cloning sample ASP.NET app..."
git clone --depth 1 --filter=blob:none --sparse `
  https://github.com/dotnet/dotnet-docker.git dotnet-docker-temp
Push-Location dotnet-docker-temp
git sparse-checkout set samples/aspnetapp/aspnetapp
Pop-Location

# Create the zip from the source project
Write-Host "Creating app.zip..."
Compress-Archive -Path ./dotnet-docker-temp/samples/aspnetapp/aspnetapp/* -DestinationPath ./app.zip -Force

# Clean up
Remove-Item -Recurse -Force dotnet-docker-temp

Write-Host "app.zip created successfully."
