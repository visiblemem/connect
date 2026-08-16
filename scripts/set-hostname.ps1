param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidatePattern('^[A-Za-z0-9](?:[A-Za-z0-9.-]*[A-Za-z0-9])?$')]
    [string]$Hostname
)

$ErrorActionPreference = 'Stop'
$templatePath = Join-Path $PSScriptRoot '..\meshcentral\config.example.json'
$configDir = Join-Path $PSScriptRoot '..\meshcentral\data'
$configPath = Join-Path $configDir 'config.json'

if (-not (Test-Path $templatePath)) {
    throw "Missing configuration template: $templatePath"
}

New-Item -ItemType Directory -Path $configDir -Force | Out-Null
(Get-Content $templatePath -Raw).Replace('CONNECT_HOSTNAME', $Hostname) |
    Set-Content -Path $configPath -Encoding utf8NoBOM

Write-Host "Configured Connect for https://$Hostname"
Write-Host "Initialize the admin locally before exposing the tunnel."
