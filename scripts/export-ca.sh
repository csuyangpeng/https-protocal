#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT_DIR/certs/rootCA.pem"

if ! command -v mkcert &>/dev/null; then
  echo "错误: 未找到 mkcert"
  exit 1
fi

CAROOT="$(mkcert -CAROOT)"
if [[ ! -f "$CAROOT/rootCA.pem" ]]; then
  echo "错误: 未找到根证书，请先运行 ./scripts/gen-cert.sh"
  exit 1
fi

mkdir -p "$ROOT_DIR/certs"
cp "$CAROOT/rootCA.pem" "$OUT"

LAN_IP="$(hostname -I 2>/dev/null | awk '{print $1}' || true)"

echo "根证书已导出: $OUT"
echo ""
echo "将此文件复制到【打开浏览器的那台电脑】，安装为受信任根证书（仅首次）:"
echo ""
if [[ -n "${LAN_IP:-}" ]]; then
  echo "  访问地址: https://${LAN_IP}:5173"
  echo ""
fi
echo "  Windows: certutil -addstore -user Root rootCA.pem"
echo "           （勿直接双击 .pem；或重命名为 .crt 后双击安装）"
echo "  macOS:   双击 rootCA.pem → 钥匙串访问 → 将该证书设为「始终信任」"
echo "  Linux:   sudo cp rootCA.pem /usr/local/share/ca-certificates/mkcert-dev.crt && sudo update-ca-certificates"
echo ""
echo "  传文件示例: scp $OUT user@客户端IP:/tmp/"
