# Connect

Connect 是一套自架的瀏覽器遠端桌面入口：人在外面時，用瀏覽器登入，就能控制已安裝 Agent 的 Windows 與 macOS 電腦。

第一版採用 [MeshCentral](https://github.com/Ylianst/MeshCentral) 作為經過實戰驗證的遠端桌面核心，避免自行發明高風險的鍵盤、滑鼠與畫面傳輸協定。它支援瀏覽器遠端桌面、WebSocket relay、WebRTC，以及 Windows/macOS Agent。

## 架構

```text
外部瀏覽器
    │ HTTPS / WebSocket
    ▼
Cloudflare Tunnel（不開放路由器連接埠）
    │
    ▼
Connect / MeshCentral Server
    │ 加密的主動連線
    ├── Windows Agent
    └── macOS Agent
```

網頁不能單獨取得作業系統的完整控制權。每台被控電腦都必須由本人安裝 Agent，macOS 還需要手動允許「螢幕錄製」與「輔助使用」權限。

## 目前功能

- 從 Chrome、Edge 或 Safari 登入控制台
- 顯示 Windows/macOS 裝置在線狀態
- 遠端觀看並操作完整桌面
- 支援剪貼簿與多螢幕（依 Agent/瀏覽器能力）
- 不需將 RDP、VNC 或 SSH 連接埠暴露到 Internet
- Server 與資料使用 Docker volume 持久化
- 預設只綁定本機 `127.0.0.1:8443`

## 快速開始

### 1. 準備

安裝 Docker Desktop（Windows/macOS）或 Docker Engine（Linux）。

### 2. 建立設定

macOS/Linux：

```bash
cp meshcentral/config.example.json meshcentral/config.json
./scripts/set-hostname.sh connect.example.com
```

Windows PowerShell：

```powershell
Copy-Item meshcentral/config.example.json meshcentral/config.json
./scripts/set-hostname.ps1 connect.example.com
```

把 `connect.example.com` 換成你要使用的網域。

### 3. 先只在本機啟動

```bash
docker compose up -d
```

開啟 `https://localhost:8443`。第一次是自簽憑證警告，僅限這個本機初始化階段。建立唯一的管理員帳號後，停止服務：

```bash
docker compose down
```

將 `meshcentral/config.json` 裡的 `"newAccounts": true` 改成 `false`，再重新啟動。不要在允許新帳號註冊時開放外網。

### 4. 建立外網入口

在 Cloudflare Zero Trust 建立 Tunnel，將 Public Hostname 的服務指向：

```text
https://host.docker.internal:8443
```

Origin TLS 設定啟用 `No TLS Verify`。Linux 若無法解析 `host.docker.internal`，可改指向主機的 Docker gateway，或把 cloudflared 加入同一個 compose network。

這個 hostname 必須與 `meshcentral/config.json` 的 `cert`、`certUrl` 完全一致。Cloudflare Access 不應直接套在所有路徑，否則 Agent 的長連線可能被登入頁攔截；第一版以 MeshCentral 帳號、強密碼和 2FA 保護入口。

### 5. 安裝被控電腦 Agent

登入控制台：

1. 建立 Device Group。
2. 選擇 Add Agent。
3. 在本人擁有或獲授權的 Windows/macOS 電腦下載並安裝。
4. macOS 到「系統設定 → 隱私權與安全性」，允許 Agent 的螢幕錄製與輔助使用。
5. 裝置上線後，進入 Desktop 頁籤開始操作。

## 上線前安全清單

- [ ] `newAccounts` 已設為 `false`
- [ ] 管理員使用長且唯一的密碼
- [ ] 管理員已啟用 TOTP 或安全金鑰 2FA
- [ ] Docker 的 8443 僅綁定 `127.0.0.1`
- [ ] 沒有在路由器開放 RDP 3389、VNC 5900 或 SSH 22
- [ ] `meshcentral/config.json`、資料庫與備份未提交 Git
- [ ] 僅在本人擁有或明確授權的電腦安裝 Agent
- [ ] 定期備份 `meshcentral/data` 與 `meshcentral/backup`

## 更新與備份

版本固定在 `docker-compose.yml`，不要自動追蹤 `latest`。更新前先閱讀 MeshCentral release notes 並備份：

```bash
docker compose down
tar -czf connect-backup.tar.gz meshcentral/data meshcentral/backup
docker compose pull
docker compose up -d
```

## 授權與界線

本專案的部署包可自行修改；遠端控制核心 MeshCentral 使用 Apache-2.0 License。只能用於你擁有或已明確獲准管理的裝置。
