# React + Go HTTPS Demo

最小可运行的 React 前端 + Go 后端 HTTPS 全栈示例。使用 [mkcert](https://github.com/FiloSottile/mkcert) 签发受信任证书，浏览器无告警。

## 前置条件

**开发机（Linux）：**

- Go 1.21+
- Node 18+
- pnpm（`npm install -g pnpm`）
- mkcert（[安装说明](https://github.com/FiloSottile/mkcert#installation)）
- Chrome/Firefox 本机信任（仅首次）：`sudo apt install -y libnss3-tools && mkcert -install`

## 一键启动

```bash
./dev.sh
```

脚本会自动：安装本地 CA → 生成证书 → 启动后端和前端。

本机浏览器打开 **https://localhost:5173**，地址栏显示安全。

## 浏览器在另一台电脑上

mkcert 的信任只装在**开发机**上。其他电脑通过局域网访问时，客户端需**一次性**安装根证书，之后永久无告警。

### 1. 开发机导出根证书

```bash
./scripts/export-ca.sh
scp certs/rootCA.pem user@客户端IP:/tmp/
```

### 2. 客户端安装根证书（仅首次）

#### Windows（推荐命令行）

> 注意：Windows **不能**直接双击 `.pem` 安装，会提示「选择打开方式」。

在 CMD 或 PowerShell 中执行：

```cmd
cd /d C:\path\to\rootCA.pem所在目录
certutil -addstore -user Root rootCA.pem
```

看到 `CertUtil: -addstore command completed successfully` 即成功。

**图形界面（备选）：** 将 `rootCA.pem` 重命名为 `rootCA.crt` → 双击 → 安装证书 → 本地计算机 → 受信任的根证书颁发机构。

#### macOS

双击 `rootCA.pem` → 钥匙串访问 → 将该证书设为「始终信任」。

#### Linux

```bash
sudo cp rootCA.pem /usr/local/share/ca-certificates/mkcert-dev.crt
sudo update-ca-certificates
```

### 3. 访问

完全关闭浏览器后重新打开，访问：

```
https://<开发机IP>:5173
```

例如 `https://10.18.1.20:5173`（IP 以 `./dev.sh` 启动时终端打印为准）。

## 手动启动（可选）

```bash
./scripts/gen-cert.sh          # 生成/更新证书
cd backend && go run main.go   # 终端 1
cd frontend && pnpm dev        # 终端 2
```

## 端口说明

| 服务 | 地址 |
|------|------|
| 前端 (Vite) | https://localhost:5173 |
| 后端 (Go) | https://0.0.0.0:8443 |

## API

- `GET /api/hello` — 返回 `{"message":"Hello from Go HTTPS!"}`
- `GET /api/health` — 返回 `{"status":"ok"}`

## 项目结构

```
https/
├── backend/              # Go HTTPS API
├── frontend/             # Vite + React (pnpm)
├── certs/                # mkcert 证书（gitignore）
├── scripts/gen-cert.sh
├── scripts/export-ca.sh  # 导出根证书给另一台电脑
├── dev.sh                # 一键启动
└── README.md
```
