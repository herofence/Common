#!/bin/bash

# 定义路径
ARGON_THEME_DIR="package/luci-theme-argon"
BACKGROUND_URL="https://raw.githubusercontent.com/herofence/openwrt/main/background.jpg"
TARGET_BG="$ARGON_THEME_DIR/htdocs/luci-static/argon/background/background.jpg"

# 确保目录存在
mkdir -p "$ARGON_THEME_DIR/htdocs/luci-static/argon/background"

# 下载并替换背景图片
echo "正在替换 Argon 主题背景图片..."
wget -q "$BACKGROUND_URL" -O "$TARGET_BG"

# 验证是否替换成功
if [ -f "$TARGET_BG" ]; then
    echo "背景图片替换成功: $TARGET_BG"
else
    echo "错误: 背景图片替换失败!"
    exit 1
fi
