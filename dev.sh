#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

echo ">> 准备 HTTPS 证书"
./scripts/gen-cert.sh

echo ">> 安装前端依赖"
(cd frontend && pnpm install --prefer-offline 2>/dev/null || pnpm install)

echo ">> 启动 Go 后端"
(cd backend && go run main.go) &
BACKEND_PID=$!
trap 'kill "$BACKEND_PID" 2>/dev/null' EXIT INT TERM

sleep 1

echo ""
echo ">> 启动前端（Ctrl+C 停止全部服务）"
echo "   本机: https://localhost:5173"
LAN_IP="$(hostname -I 2>/dev/null | awk '{print $1}' || true)"
if [[ -n "${LAN_IP:-}" ]]; then
  echo "   局域网: https://${LAN_IP}:5173"
  echo ""
  echo ">> 浏览器在【另一台电脑】上？首次需安装根证书（仅一次）:"
  echo "   ./scripts/export-ca.sh   # 导出 certs/rootCA.pem 拷过去安装"
fi
echo ""

cd frontend && pnpm dev
