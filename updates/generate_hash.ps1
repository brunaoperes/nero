# Script PowerShell para gerar o hash SHA-256 do APK

param(
    [Parameter(Mandatory=$true)]
    [string]$ApkPath
)

if (-not (Test-Path $ApkPath)) {
    Write-Error "Erro: Arquivo '$ApkPath' não encontrado!"
    exit 1
}

Write-Host "Gerando hash SHA-256 para: $ApkPath" -ForegroundColor Green
Write-Host ""

$hash = Get-FileHash -Path $ApkPath -Algorithm SHA256
Write-Host $hash.Hash.ToLower() -ForegroundColor Yellow

Write-Host ""
Write-Host "Cole este hash no campo 'apkSha256' do arquivo latest.json" -ForegroundColor Cyan
