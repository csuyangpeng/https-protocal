#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CERT_DIR="$ROOT_DIR/certs"

mkdir -p "$CERT_DIR"

if ! command -v mkcert &>/dev/null; then
  echo "错误: 未找到 mkcert"
  echo "安装: https://github.com/FiloSottile/mkcert#installation"
  exit 1
fi

echo ">> 安装本地 CA（仅首次需要，浏览器将信任后续证书）"
mkcert -install

if ! command -v certutil &>/dev/null; then
  echo ""
  echo ">> 提示: Chrome/Firefox 需要 certutil 才能自动信任证书，请执行："
  echo "   sudo apt install -y libnss3-tools && mkcert -install"
  echo ""
fi

HOSTS=(localhost 127.0.0.1 ::1)
LAN_IP="$(hostname -I 2>/dev/null | awk '{print $1}' || true)"
if [[ -n "${LAN_IP:-}" ]]; then
  HOSTS+=("$LAN_IP")
fi

echo ">> 生成受信任证书: ${HOSTS[*]}"
mkcert -key-file "$CERT_DIR/server.key" -cert-file "$CERT_DIR/server.crt" "${HOSTS[@]}"

echo ""
echo "证书已就绪（浏览器不会显示不安全警告）:"
echo "  $CERT_DIR/server.crt"
echo "  $CERT_DIR/server.key"
