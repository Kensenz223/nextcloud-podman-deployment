[CmdletBinding()]
param(
    [string]$ComposeFile = (Join-Path $PSScriptRoot 'compose.yaml')
)

$ErrorActionPreference = 'Stop'
$envFile = Join-Path $PSScriptRoot '.env'

if (-not (Test-Path $envFile)) {
    throw "找不到 .env。請先複製 .env.example 為 .env，並在本機填入必要值。"
}

Write-Host '正在確認 Podman machine 狀態。'
podman machine start 2>$null

Write-Host '正在啟動 Nextcloud、PostgreSQL 與 Redis。'
podman compose --env-file $envFile -f $ComposeFile up -d

Write-Host '服務啟動命令已完成。請使用 podman ps -a 及 Nextcloud 網頁介面確認狀態。'
