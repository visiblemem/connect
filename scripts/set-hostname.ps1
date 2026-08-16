param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidatePattern('^[A-Za-z0-9](?:[A-Za-z0-9.-]*[A-Za-z0-9])?$')]
    [string]$Hostname
)

$ErrorActionPreference = 'Stop'
$templatePath = Join-Path $PSScriptRoot '..\meshcentral\config.example.json'
$configPath = Join-Path $PSScriptRoot '..\meshcentral\config.json'

if (-not (Test-Path $templatePath)) {
    throw "Missing configuration template: $templatePath"
}

(Get-Content $templatePath -Raw).Replace('CONNECT_HOSTNAME', $Hostname) |
    Set-Content -Path $configPath -Encoding utf8NoBOM

Write-Host "Configured Connect for https://$Hostname"
Write-Host "Initialize the admin locally before exposing the tunnel."
