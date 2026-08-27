[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Destination
)

$ErrorActionPreference = 'Stop'
$envFile = Join-Path $PSScriptRoot '.env'
if (-not (Test-Path $envFile)) { throw '找不到 .env；備份需要本機資料庫設定。' }

New-Item -ItemType Directory -Force -Path $Destination | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$dbDump = Join-Path $Destination "nextcloud-db-$stamp.sql"

# 只在目前 PowerShell 程序記憶體中讀取必要值，不輸出密碼。
$envLines = Get-Content $envFile | Where-Object { $_ -match '^\s*([^#][^=]*)=(.*)$' }
foreach ($line in $envLines) {
    $m = [regex]::Match($line, '^\s*([^#][^=]*)=(.*)$')
    [Environment]::SetEnvironmentVariable($m.Groups[1].Value.Trim(), $m.Groups[2].Value.Trim(), 'Process')
}

Write-Host '正在建立 PostgreSQL dump。'
$oldErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$dump = podman exec -e "PGPASSWORD=$env:POSTGRES_PASSWORD" nextcloud-db pg_dump -U $env:POSTGRES_USER -d $env:POSTGRES_DB
$exitCode = $LASTEXITCODE
$ErrorActionPreference = $oldErrorActionPreference
if ($exitCode -ne 0) { throw "PostgreSQL dump 失敗，exit code $exitCode。" }
$dump | Set-Content -Encoding UTF8 -Path $dbDump

Write-Host "資料庫備份已建立：$dbDump"
Write-Host '請另行以加密方式備份 nextcloud_html volume 與 .env；不要把備份檔或 .env 放入 GitHub。'
