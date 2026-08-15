#!/bin/bash
#
# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
sed -i "s/ImmortalWrt/OpenWrt/g" package/base-files/files/bin/config_generate
# 修复或重置 dockerd 包，使用稳定来源
rm -rf feeds/packages/utils/dockerd
git clone https://github.com/openwrt/packages.git --depth=1 /tmp/openwrt-packages
cp -r /tmp/openwrt-packages/utils/dockerd feeds/packages/utils/dockerd
rm -rf /tmp/openwrt-packages
