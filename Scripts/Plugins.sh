#!/bin/bash

#Linkease
git clone --depth=1 --single-branch https://github.com/linkease/istore.git
git clone --depth=1 --single-branch https://github.com/linkease/nas-packages.git
git clone --depth=1 --single-branch https://github.com/linkease/nas-packages-luci.git
#Design Theme
if [[ $OWRT_URL == *"lede"* ]] ; then
  git clone --depth=1 --single-branch --branch "main" https://github.com/gngpp/luci-theme-design.git
else
  git clone --depth=1 --single-branch --branch "js" https://github.com/papagaye744/luci-theme-design.git
fi
git clone --depth=1 --single-branch https://github.com/gngpp/luci-app-design-config.git
#Argon Theme
git clone --depth=1 --single-branch --branch $(echo $OWRT_URL | grep -iq "lede" && echo "18.06" || echo "master") https://github.com/jerrykuku/luci-theme-argon.git
git clone --depth=1 --single-branch --branch $(echo $OWRT_URL | grep -iq "lede" && echo "18.06" || echo "master") https://github.com/jerrykuku/luci-app-argon-config.git
#Pass Wall
git clone --depth=1 --single-branch https://github.com/xiaorouji/openwrt-passwall.git
git clone --depth=1 --single-branch https://github.com/xiaorouji/openwrt-passwall-packages.git
#Hello World
git clone --depth=1 --single-branch https://github.com/fw876/helloworld.git
#OpenAppFilter
git clone --depth=1 --single-branch https://github.com/destan19/OpenAppFilter.git
#Fros
git clone --depth=1 --single-branch https://github.com/openfros/fros.git
