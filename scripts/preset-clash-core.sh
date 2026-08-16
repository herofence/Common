#!/bin/bash
# OpenClash 核心文件下载脚本
# 用法: ./preset-clash-core.sh [架构]
# 架构参数: amd64, arm64, armv7 等

set -e  # 遇到错误立即退出

# 检查架构参数
ARCH="${1:-amd64}"
echo "目标架构: $ARCH"

# 创建目录
mkdir -p files/etc/openclash/core

# 定义颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 下载文件的函数（带重试机制）
download_file() {
    local url="$1"
    local output="$2"
    local max_retries=3
    local retry_count=0
    
    if [ -z "$url" ] || [ "$url" = "null" ]; then
        print_error "URL 为空，跳过下载: $output"
        return 1
    fi
    
    while [ $retry_count -lt $max_retries ]; do
        if wget -q --timeout=30 --tries=3 "$url" -O "$output"; then
            if [ -s "$output" ]; then
                print_info "下载成功: $output"
                return 0
            else
                print_warn "下载的文件为空: $output"
                rm -f "$output"
            fi
        else
            print_warn "下载失败 (尝试 $((retry_count + 1))/$max_retries): $url"
        fi
        retry_count=$((retry_count + 1))
        sleep 2
    done
    
    print_error "下载失败: $url"
    return 1
}

# 下载 GeoIP 数据
print_info "下载 GeoIP 数据..."
download_file "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat" "files/etc/openclash/GeoIP.dat"
download_file "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat" "files/etc/openclash/GeoSite.dat"

# 获取 Clash 核心版本信息
print_info "获取 Clash 核心版本信息..."

# 1. Dev 版本
DEV_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/dev/clash-linux-${ARCH}.tar.gz"
print_info "Dev 版本 URL: $DEV_URL"

# 2. TUN 版本（从 GitHub API 获取）
TUN_URL=$(curl -fsSL "https://api.github.com/repos/vernesong/OpenClash/contents/master/premium?ref=core" 2>/dev/null | \
    grep -o '"download_url": "[^"]*"' | \
    grep "$ARCH" | \
    head -1 | \
    awk -F '"' '{print $4}' 2>/dev/null || echo "")

if [ -z "$TUN_URL" ] || [ "$TUN_URL" = "null" ]; then
    print_warn "无法获取 TUN 版本下载链接，尝试使用备用 URL"
    # 备用：直接构造 URL（需要确认具体版本号）
    TUN_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/premium/clash-linux-${ARCH}-v3.tar.gz"
fi
print_info "TUN 版本 URL: $TUN_URL"

# 3. Meta 版本
META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-${ARCH}.tar.gz"
print_info "Meta 版本 URL: $META_URL"

# 下载并解压 Dev 版本
print_info "下载 Dev 核心..."
if wget -q --timeout=30 --tries=3 "$DEV_URL" -O /tmp/clash_dev.tar.gz 2>/dev/null; then
    tar -xzf /tmp/clash_dev.tar.gz -O 2>/dev/null > files/etc/openclash/core/clash
    chmod +x files/etc/openclash/core/clash
    print_info "Dev 核心下载成功"
    rm -f /tmp/clash_dev.tar.gz
else
    print_error "Dev 核心下载失败"
fi

# 下载并解压 TUN 版本
print_info "下载 TUN 核心..."
if [ -n "$TUN_URL" ] && [ "$TUN_URL" != "null" ]; then
    if wget -q --timeout=30 --tries=3 "$TUN_URL" -O /tmp/clash_tun.gz 2>/dev/null; then
        if gunzip -c /tmp/clash_tun.gz 2>/dev/null > files/etc/openclash/core/clash_tun; then
            chmod +x files/etc/openclash/core/clash_tun
            print_info "TUN 核心下载成功"
        else
            print_warn "TUN 核心解压失败，可能不是 gzip 格式"
            # 尝试作为 tar.gz 解压
            if tar -xzf /tmp/clash_tun.gz -O 2>/dev/null > files/etc/openclash/core/clash_tun; then
                chmod +x files/etc/openclash/core/clash_tun
                print_info "TUN 核心（tar.gz格式）下载成功"
            fi
        fi
        rm -f /tmp/clash_tun.gz
    else
        print_error "TUN 核心下载失败"
    fi
else
    print_error "TUN 核心 URL 无效"
fi

# 下载并解压 Meta 版本
print_info "下载 Meta 核心..."
if wget -q --timeout=30 --tries=3 "$META_URL" -O /tmp/clash_meta.tar.gz 2>/dev/null; then
    tar -xzf /tmp/clash_meta.tar.gz -O 2>/dev/null > files/etc/openclash/core/clash_meta
    chmod +x files/etc/openclash/core/clash_meta
    print_info "Meta 核心下载成功"
    rm -f /tmp/clash_meta.tar.gz
else
    print_error "Meta 核心下载失败"
fi

# 如果所有核心都下载失败，创建一个占位文件避免编译错误
check_core_files() {
    local missing=0
    for core in clash clash_tun clash_meta; do
        if [ ! -f "files/etc/openclash/core/$core" ]; then
            print_warn "核心文件缺失: $core"
            # 创建空文件占位，避免编译错误
            echo "#!/bin/sh" > "files/etc/openclash/core/$core"
            echo "echo 'OpenClash core $core not available'" >> "files/etc/openclash/core/$core"
            chmod +x "files/etc/openclash/core/$core"
            missing=$((missing + 1))
        fi
    done
    if [ $missing -eq 0 ]; then
        print_info "所有核心文件下载完成！"
    else
        print_warn "$missing 个核心文件缺失，已创建占位文件"
    fi
}

check_core_files

# 显示最终文件列表
print_info "OpenClash 核心文件列表:"
ls -lh files/etc/openclash/core/ 2>/dev/null || echo "目录为空"

print_info "脚本执行完成"
