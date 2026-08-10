#!/bin/bash

#移除dnsmasq冲突
sed -i '/CONFIG_PACKAGE_dnsmasq/d' .config
echo "CONFIG_PACKAGE_dnsmasq=n" >> .config

#确保OpenClash被选中（防止sed匹配失败）
sed -i '/CONFIG_PACKAGE_luci-app-openclash/d' .config
echo "CONFIG_PACKAGE_luci-app-openclash=y" >> .config

#验证OpenClash是否被正确选中
if grep -q "CONFIG_PACKAGE_luci-app-openclash=y" .config; then
    echo "? OpenClash 配置成功！"
else
    echo "? OpenClash 配置失败！"
    echo "当前 .config 中 OpenClash 相关配置："
    grep -i "openclash" .config || echo "未找到 OpenClash 配置"
fi

# 仅预置GeoIP和GeoSite数据库

mkdir -p files/etc/openclash/core

GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"

echo "正在下载 GeoIP 和 GeoSite 数据库..."
wget -qO- $GEOIP_URL > files/etc/openclash/GeoIP.dat && echo "? GeoIP.dat 下载成功" || echo "? GeoIP.dat 下载失败"
wget -qO- $GEOSITE_URL > files/etc/openclash/GeoSite.dat && echo "? GeoSite.dat 下载成功" || echo "? GeoSite.dat 下载失败"

# 创建空的内核文件占位（可选）
touch files/etc/openclash/core/clash
touch files/etc/openclash/core/clash_tun
touch files/etc/openclash/core/clash_meta
echo "? 数据库预置完成（内核文件为空，用户可在线下载）"
