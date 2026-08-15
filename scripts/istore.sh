#!/bin/sh

# 切换到 OpenWrt 源码目录（如果脚本在外部调用）
OPENWRT_DIR="${OPENWRT_DIR:-.}"
cd "$OPENWRT_DIR" || exit 1

# 1. 添加 iStore 相关 feeds 源
echo >> feeds.conf.default
echo 'src-git istore https://github.com/linkease/istore;main' >> feeds.conf.default
echo 'src-git nas https://github.com/linkease/nas-packages.git;master' >> feeds.conf.default
echo 'src-git nas_luci https://github.com/linkease/nas-packages-luci.git;main' >> feeds.conf.default

# 2. 统一更新所有 feeds（先更新所有源，再安装）
./scripts/feeds update -a

# 3. 只安装必要的包（避免全部安装）
./scripts/feeds install -d y -p istore luci-app-store
# ./scripts/feeds install -d y -p nas luci-app-easymesh  # 如果易有云需要
# ./scripts/feeds install -d y -p nas_luci luci-app-easymesh  # 易有云 Luci 界面
