#!/bin/bash

# Merge_package
function merge_package(){
    repo=`echo $1 | rev | cut -d'/' -f 1 | rev`
    pkg=`echo $2 | rev | cut -d'/' -f 1 | rev`
    # find package/ -follow -name $pkg -not -path "package/openwrt-packages/*" | xargs -rt rm -rf
    git clone --depth=1 --single-branch $1
    [ -d package/openwrt-packages ] || mkdir -p package/openwrt-packages
    mv $2 package/openwrt-packages/
    rm -rf $repo
}

rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config

# Clone community packages to package/community
mkdir package/community
pushd package/community
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns package/luci-app-mosdns
git clone https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
git clone https://github.com/y9858/luci-theme-opentomcat package/luci-theme-opentomcat
git clone --depth=1 -b lede https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns
git clone https://github.com/lisaac/luci-app-diskman package/applications/luci-app-diskman
git clone https://github.com/gdy666/luci-app-lucky.git package/lucky
git clone --depth=1 https://github.com/linkease/istore package/istore
git clone --depth=1 https://github.com/linkease/nas-packages package/nas-packages
git clone --depth=1 https://github.com/linkease/nas-packages-luci package/nas-packages-luci
git clone https://github.com/sirpdboy/netspeedtest.git package/netspeedtest
git clone https://github.com/lmq8267/luci-app-vnt.git package/vnt
git clone https://github.com/cg8-5712/vnt.git package/vnt
git clone --depth=1 https://github.com/EasyTier/luci-app-easytier package/luci-app-easytier
git clone --depth=1 -b openwrt-18.06 https://github.com/tty228/luci-app-wechatpush package/luci-app-serverchan
git clone --depth=1 https://github.com/ilxp/luci-app-ikoolproxy package/luci-app-ikoolproxy
git clone --depth=1 https://github.com/esirplayground/luci-app-poweroff package/luci-app-poweroff
git clone --depth=1 https://github.com/Jason6111/luci-app-netdata package/luci-app-netdata
git_sparse_clone main https://github.com/Lienol/openwrt-package luci-app-filebrowser luci-app-ssr-mudb-server
git_sparse_clone openwrt-18.06 https://github.com/immortalwrt/luci applications/luci-app-eqos
git clone --depth=1 https://github.com/vernesong/OpenClash.git package/luci-app-openclash
git clone https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall
git clone https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwal
popd

# add luci-app-mosdns
rm -rf feeds/packages/net/v2ray-geodata
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
