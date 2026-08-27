[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory = $true)]
    [string]$DatabaseDump
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path $DatabaseDump)) { throw "找不到資料庫備份：$DatabaseDump" }

Write-Warning '此操作會覆寫 nextcloud-db 中的資料。請先確認已有目前服務的完整備份。'
if (-not $PSCmdlet.ShouldProcess('nextcloud-db', '還原 PostgreSQL dump')) { return }

$secure = Read-Host '輸入 PostgreSQL 密碼' -AsSecureString
$plain = (New-Object System.Management.Automation.PSCredential('postgres', $secure)).GetNetworkCredential().Password
try {
    Get-Content -Raw -Path $DatabaseDump | podman exec -i -e "PGPASSWORD=$plain" nextcloud-db psql -U $env:POSTGRES_USER -d $env:POSTGRES_DB
    if ($LASTEXITCODE -ne 0) { throw "PostgreSQL 還原失敗，exit code $LASTEXITCODE。" }
} finally {
    $plain = $null
}

Write-Host '資料庫還原命令已完成。請檢查 maintenance mode、檔案權限與應用程式版本。'
