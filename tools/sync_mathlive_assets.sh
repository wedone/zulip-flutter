#!/usr/bin/env bash
# 从本地 mathlive 仓库同步构建产物到 zulip-flutter 的 assets 目录
#
# 用法：bash tools/sync_mathlive_assets.sh
#
# 前置条件：
#   - /mnt/d/vc/mathlive/ 下已执行 pnpm build 生成 dist/ 目录
#   - 如未构建，脚本会自动执行 pnpm build

set -euo pipefail

# 源目录（mathlive 仓库）
SRC_DIR="${MATHLIVE_REPO:-/mnt/d/vc/mathlive}"
DIST_DIR="$SRC_DIR/dist"

# 目标目录（zulip-flutter assets）
DEST_DIR="$(cd "$(dirname "$0")/.." && pwd)/assets/mathlive"

echo "=== MathLive 资源同步 ==="
echo "源目录: $DIST_DIR"
echo "目标目录: $DEST_DIR"
echo ""

# 检查源目录
if [ ! -d "$DIST_DIR" ]; then
  echo "未找到 dist/ 目录，执行 pnpm build..."
  cd "$SRC_DIR" && pnpm build
fi

# 检查关键文件
for f in mathlive.min.js mathlive-static.css; do
  if [ ! -f "$DIST_DIR/$f" ]; then
    echo "错误: $DIST_DIR/$f 不存在" >&2
    exit 1
  fi
done

if [ ! -d "$DIST_DIR/fonts" ]; then
  echo "错误: $DIST_DIR/fonts/ 目录不存在" >&2
  exit 1
fi

# 同步 JS
cp "$DIST_DIR/mathlive.min.js" "$DEST_DIR/mathlive.min.js"
JS_SIZE=$(stat -c%s "$DEST_DIR/mathlive.min.js" 2>/dev/null || stat -f%z "$DEST_DIR/mathlive.min.js")
echo "✓ mathlive.min.js ($JS_SIZE bytes)"

# 同步 CSS
cp "$DIST_DIR/mathlive-static.css" "$DEST_DIR/mathlive-static.css"
CSS_SIZE=$(stat -c%s "$DEST_DIR/mathlive-static.css" 2>/dev/null || stat -f%z "$DEST_DIR/mathlive-static.css")
echo "✓ mathlive-static.css ($CSS_SIZE bytes)"

# 同步字体目录
mkdir -p "$DEST_DIR/fonts"
cp -r "$DIST_DIR/fonts/"*.woff2 "$DEST_DIR/fonts/"
FONT_COUNT=$(ls "$DEST_DIR/fonts/"*.woff2 2>/dev/null | wc -l)
echo "✓ fonts/ ($FONT_COUNT 个 woff2 文件)"

# 提取版本号
VERSION=$(grep -oE '/\*\* MathLive [0-9.]+' "$DEST_DIR/mathlive.min.js" | head -1 | grep -oE '[0-9.]+' || echo "unknown")
echo ""
echo "=== 同步完成 ==="
echo "MathLive 版本: $VERSION"
echo ""
echo "注意：mathlive_editor.html 由 zulip-flutter 端维护，本脚本不同步。"
