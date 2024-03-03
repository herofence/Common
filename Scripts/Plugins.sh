#!/bin/bash

#lucky
git clone --depth=1 --single-branch https://github.com/gdy666/luci-app-lucky.git
#Linkease
git clone --depth=1 --single-branch https://github.com/linkease/istore.git
git clone --depth=1 --single-branch https://github.com/linkease/nas-packages.git
git clone --depth=1 --single-branch https://github.com/linkease/nas-packages-luci.git
#Design Theme
git clone --depth=1 --single-branch --branch "main" https://github.com/gngpp/luci-theme-design.git
git clone --depth=1 --single-branch https://github.com/gngpp/luci-app-design-config.git
#Argon Theme
git clone --depth=1 --single-branch --branch $(echo $OWRT_URL | grep -iq "lede" && echo "18.06" || echo "master") https://github.com/jerrykuku/luci-theme-argon.git
git clone --depth=1 --single-branch --branch $(echo $OWRT_URL | grep -iq "lede" && echo "18.06" || echo "master") https://github.com/jerrykuku/luci-app-argon-config.git
#Pass Wall
git clone --depth=1 --single-branch https://github.com/xiaorouji/openwrt-passwall.git
#git clone --depth=1 --single-branch https://github.com/xiaorouji/openwrt-passwall-packages.git
#Hello World
#git clone --depth=1 --single-branch https://github.com/fw876/helloworld.git
#应用过滤器
#git clone --depth=1 --single-branch https://github.com/destan19/OpenAppFilter.git
