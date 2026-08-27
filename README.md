# Nextcloud on Podman Desktop

本 repository 保存 Windows Podman Desktop 上 Nextcloud 服務的**部署程式碼與設定範本**，不保存 Nextcloud 使用者檔案、資料庫內容、Redis 資料、登入密碼或任何私密金鑰。

## 目前部署概況

目前 Windows 主機上的服務包含：

| 元件 | Pod／container | 映像 | 持久化資料 |
|---|---|---|---|
| Nextcloud | `nextcloud-pod` / `nextcloud-app` | `docker.io/library/nextcloud:apache` | `nextcloud_html` |
| PostgreSQL | `nextcloud-pod` / `nextcloud-db` | `docker.io/library/postgres:16-alpine` | `nextcloud_pgdata` |
| Redis | `nextcloud-pod` / `nextcloud-redis` | `docker.io/library/redis:7-alpine` | `nextcloud_redisdata` |
| Talk HPB | `talk-hpb-pod` / `nextcloud-talk-hpb` | `ghcr.io/nextcloud-releases/aio-talk:latest` | 依服務設定而定 |

目前的 `Caddyfile` 反向代理至本機 Nextcloud HTTP port。請注意，Caddyfile 中的主機名稱屬於環境設定；若 repository 要分享給其他人，應將其改成範例主機名稱。

## 使用方式

第一次建立本機設定時，請複製 `.env.example` 為 `.env`，填入唯一且強健的密碼與 secrets。`.env` 已被 `.gitignore` 排除，絕對不要提交、附加或貼到公開訊息中。

主 Nextcloud 服務可使用：

```powershell
.\Start-Nextcloud.ps1
```

Talk HPB 是獨立服務，只有在已完成主 Nextcloud、反向代理、TURN、Windows Firewall 與網路測試後才應啟動：

```powershell
podman compose -f compose.talk-hpb.yaml up -d
```

這些 Compose 檔案是根據目前執行中的服務整理出的**可重建範本**。在正式還原前，請先在測試環境驗證映像版本、trusted domains、反向代理與 Talk signalling 設定；不要直接刪除目前正在使用的 pod 或 named volumes。

## 備份與還原

備份前應先確認目的地位於不同磁碟或不同主機，並同時備份 PostgreSQL dump、Nextcloud application/data 內容與本機 `.env`。`.env` 不可提交到 GitHub，應以離線密碼管理器或加密儲存保存。

```powershell
.\Backup-Nextcloud.ps1 -Destination 'E:\Nextcloud-Backups'
```

還原是破壞性操作。執行 `Restore-Nextcloud.ps1` 前，請確認目前服務已備份、維護時段已安排，而且目標 volumes 確實是要覆寫的資料；不要把測試備份還原到正式服務。

## GitHub 安全原則

本 repository 應設定為 **Private**。提交前請檢查：

```powershell
git status --short
git diff --cached
```

不可提交的內容包括 `.env`、`config.php`、Nextcloud `data`、PostgreSQL／Redis volumes、database dumps、TLS private keys、TURN／signalling／internal secrets，以及任何包含使用者資料的壓縮檔。

## 相關官方文件

Nextcloud Container：[github.com/nextcloud/docker](https://github.com/nextcloud/docker)

Nextcloud reverse proxy：[docs.nextcloud.com/server/stable/admin_manual/configuration_server/reverse_proxy_configuration.html](https://docs.nextcloud.com/server/stable/admin_manual/configuration_server/reverse_proxy_configuration.html)

Nextcloud Talk installation：[nextcloud-talk.readthedocs.io/en/latest/quick-install](https://nextcloud-talk.readthedocs.io/en/latest/quick-install/)
