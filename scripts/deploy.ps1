#Requires -Version 5.1
<#
    Sets up a local development environment for ucl-open/rigs.
    - Bootstraps the Bonsai environment from .bonsai/Bonsai.config
    - Builds and installs UclOpen NuGet packages into the Bonsai environment
    - Installs the Python package using uv
    - Generates the unified experiment schema (YAML instance + JSON Schema)
    - Runs bonsai.sgen via aind_behavior_services to produce C# classes in test/Extensions/
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RootDir = $PSScriptRoot

# --- Bonsai bootstrap + package restore ---

Write-Host "Setting up Bonsai environment..."

Push-Location $RootDir
try {
    & (Join-Path $RootDir ".bonsai" "Setup.ps1")
} finally {
    Pop-Location
}

Write-Host "Bonsai environment ready."

# --- .NET tools ---

Write-Host ""
Write-Host "Restoring .NET tools..."

Push-Location $RootDir
try {
    dotnet tool restore --nologo 2>&1 | Write-Host
} finally {
    Pop-Location
}

Write-Host ".NET tools restored."

# --- Build UclOpen packages ---

Write-Host ""
Write-Host "Building UclOpen packages..."

Push-Location $RootDir
try {
    dotnet pack UclOpen.sln -c Release --nologo 2>&1 | Where-Object { $_ -match "Successfully|error" } | Write-Host
} finally {
    Pop-Location
}

Write-Host "UclOpen packages built."

# --- Python setup ---

Write-Host ""
Write-Host "Setting up Python environment..."

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "  uv not found, installing..."
    Invoke-WebRequest -Uri "https://astral.sh/uv/install.ps1" -OutFile "$env:TEMP\install-uv.ps1"
    & "$env:TEMP\install-uv.ps1"
    Remove-Item "$env:TEMP\install-uv.ps1"
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";" + $env:PATH
}

Push-Location $RootDir
try {
    uv sync
    Write-Host "Python environment ready."
} finally {
    Pop-Location
}

# --- Generate experiment schema + C# classes ---

Write-Host ""
Write-Host "Generating experiment schema and C# classes..."

Push-Location $RootDir
try {
    uv run python test/schema.py
    Write-Host "  Schema and C# classes generated."
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "Setup complete."
Write-Host "  Run Bonsai:  .\.bonsai\Bonsai.exe"
