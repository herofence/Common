#!/bin/bash
# 使用 lisaac/luci-app-dockerman 仓库修复 Docker 编译问题

echo "========================================="
echo "开始修复 Docker 编译问题..."
echo "========================================="

# 进入 openwrt 目录
cd openwrt || exit 1

# 备份原始 feeds 配置
if [ -f feeds.conf.default ]; then
    cp feeds.conf.default feeds.conf.default.backup
    echo "已备份 feeds.conf.default"
fi

# 删除有问题的 Docker 包
echo "删除有问题的 Docker 包..."
rm -rf feeds/packages/utils/dockerd
rm -rf feeds/packages/utils/docker
rm -rf feeds/packages/utils/docker-compose
rm -rf feeds/packages/utils/containerd
rm -rf feeds/packages/utils/runc
rm -rf feeds/packages/utils/libnetwork
rm -rf feeds/luci/applications/luci-app-dockerman
rm -rf feeds/luci/applications/luci-app-docker
rm -rf feeds/luci/applications/luci-lib-docker

# 克隆 lisaac 的仓库
echo "克隆 lisaac/luci-app-dockerman 仓库..."
git clone --depth=1 https://github.com/lisaac/luci-app-dockerman.git /tmp/luci-app-dockerman

# 检查克隆是否成功
if [ ! -d "/tmp/luci-app-dockerman" ]; then
    echo "错误：无法克隆仓库"
    exit 1
fi

# 查看仓库结构
echo "仓库结构："
ls -la /tmp/luci-app-dockerman/

# 复制 luci-app-dockerman
if [ -d "/tmp/luci-app-dockerman/luci-app-dockerman" ]; then
    echo "复制 luci-app-dockerman..."
    cp -r /tmp/luci-app-dockerman/luci-app-dockerman feeds/luci/applications/
fi

# 复制 luci-lib-docker（如果存在）
if [ -d "/tmp/luci-app-dockerman/luci-lib-docker" ]; then
    echo "复制 luci-lib-docker..."
    cp -r /tmp/luci-app-dockerman/luci-lib-docker feeds/luci/libs/
fi

# 查找并复制其他可能的 Docker 相关包
echo "查找其他 Docker 相关包..."
find /tmp/luci-app-dockerman -maxdepth 2 -type d | while read dir; do
    dirname=$(basename "$dir")
    if [[ "$dirname" == *"docker"* ]] || [[ "$dirname" == *"dockerd"* ]] || [[ "$dirname" == *"containerd"* ]]; then
        echo "找到包: $dirname"
        if [[ "$dirname" == *"luci"* ]]; then
            cp -r "$dir" feeds/luci/applications/ 2>/dev/null
        else
            cp -r "$dir" feeds/packages/utils/ 2>/dev/null
        fi
    fi
done

# 清理临时文件
rm -rf /tmp/luci-app-dockerman

# 更新 feeds
echo "更新 feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# 检查 Docker 包是否已正确安装
echo "========================================="
echo "检查 Docker 相关包："
find feeds/ -name "*docker*" -type d | while read pkg; do
    echo "  - $pkg"
done
echo "========================================="

# 如果仍然没有 dockerd，尝试从其他源获取
if [ ! -d "feeds/packages/utils/dockerd" ]; then
    echo "警告：未找到 dockerd 包，尝试从 Lean's LEDE 获取..."
    
    # 从 Lean's LEDE 获取 dockerd
    git clone --depth=1 https://github.com/coolsnowwolf/lede.git /tmp/lean-lede
    
    if [ -d "/tmp/lean-lede/package/lean/dockerd" ]; then
        echo "从 Lean's LEDE 复制 dockerd..."
        cp -r /tmp/lean-lede/package/lean/dockerd feeds/packages/utils/
    fi
    
    if [ -d "/tmp/lean-lede/package/lean/docker" ]; then
        echo "从 Lean's LEDE 复制 docker..."
        cp -r /tmp/lean-lede/package/lean/docker feeds/packages/utils/
    fi
    
    # 清理
    rm -rf /tmp/lean-lede
    
    # 重新更新 feeds
    ./scripts/feeds install -a
fi

echo "========================================="
echo "Docker 修复完成！"
echo "========================================="
