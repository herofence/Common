#!/bin/sh

# 1. 将 iStore 的 feeds 源添加到配置文件
echo >> feeds.conf.default
echo 'src-git istore https://github.com/linkease/istore;main' >> feeds.conf.default
echo 'src-git nas https://github.com/linkease/nas-packages.git;master' >> feeds.conf.default
echo 'src-git nas_luci https://github.com/linkease/nas-packages-luci.git;main' >> feeds.conf.default
./scripts/feeds update nas nas_luci

# 2. 更新 feeds，获取 iStore 的包列表
./scripts/feeds update istore

# 3. 安装 iStore 的核心包 (luci-app-store) 及其依赖
./scripts/feeds install -d y -p istore luci-app-store
./scripts/feeds install -a -p nas
./scripts/feeds install -a -p nas_luci
