#!/bin/bash

merge_package(){
    # 参数1是分支名,参数2是库地址,参数3是子路径。所有文件下载到openwrt/package/openwrt-packages路径。
    # 同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开。
    branch=$1 curl=$2 && shift 2
    rootdir=$(pwd)
    localdir=package/openwrt-packages
    [ -d $localdir ] || mkdir -p $localdir
    tmpdir=$(mktemp -d) || exit 1
    git clone -b $branch --depth 1 --filter=blob:none --sparse $curl $tmpdir
    cd $tmpdir
    git sparse-checkout init --cone
    git sparse-checkout set $@
    mv -f $@ $rootdir/$localdir
	cd $rootdir && rm -rf $tmpdir
}

# 下载额外软件
git clone --depth=1 --single-branch https://github.com/gdy666/luci-app-lucky.git
merge_package master https://github.com/WYC-2020/openwrt-packages luci-app-openclash luci-app-ddnsto ddnsto 
merge_package main https://github.com/kenzok8/small-package lua-maxminddb
merge_package main https://github.com/ophub/luci-app-amlogic luci-app-amlogic
merge_package master https://github.com/kenzok8/luci-theme-ifit luci-theme-ifit
merge_package master https://github.com/lisaac/luci-app-dockerman applications/luci-app-dockerman
merge_package main https://github.com/xiaorouji/openwrt-passwall luci-app-passwall
merge_package main https://github.com/xiaorouji/openwrt-passwall2 luci-app-passwall2
merge_package main https://github.com/xiaorouji/openwrt-passwall-packages brook pdnsd-alt sing-box trojan-plus trojan-go v2ray-geodata
git clone --depth=1 -b master https://github.com/fw876/helloworld package/openwrt-packages/helloworld
git clone --depth=1 -b master https://github.com/Leo-Jo-My/luci-theme-opentomcat package/openwrt-packages/luci-theme-opentomcat
git clone --depth=1 -b master https://github.com/binge8/luci-theme-butongwifi package/openwrt-packages/luci-theme-butongwifi
git clone --depth=1 -b master https://github.com/openwrt-develop/luci-theme-atmaterial package/openwrt-packages/luci-theme-atmaterial
git clone --depth=1 -b master https://github.com/rufengsuixing/luci-app-adguardhome package/openwrt-packages/luci-app-adguardhome
git clone --depth=1 -b master https://github.com/931122/luci-app-pushbot package/openwrt-packages/luci-app-pushbot
git clone --depth=1 -b main https://github.com/sirpdboy/luci-theme-kucat package/openwrt-packages/luci-theme-kucat
# 删除重复软件包
rm -rf feeds/luci/applications/luci-app-dockerman feeds/luci/applications/luci-app-pushbot feeds/packages/net/mosdns

# 利用mnt空间
sudo mkdir -p -m 777 /mnt/openwrt/dl && ln -sf /mnt/openwrt/dl dl
sudo mkdir -p -m 777 /mnt/openwrt/staging_dir && ln -sf /mnt/openwrt/staging_dir staging_dir
sudo mkdir -p -m 777 /mnt/openwrt/feeds && ln -sf /mnt/openwrt/feeds feeds
sudo mkdir -p -m 777 /mnt/openwrt/build_dir && ln -sf /mnt/openwrt/build_dir build_dir

# 更新安装feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 设置变量
useVersionInfo=$(git show -s --date=short --format="编译前的最后一次[➦主源码](https://github.com/coolsnowwolf/lede)更新记录:<br/>更新人: %an<br/>更新时间: %cd<br/>更新内容: %s<br/>哈希值: %H")
echo "Info=$useVersionInfo" >> $GITHUB_ENV
echo "DATE=$(date +%Y年%m月%d日%H时)" >> $GITHUB_ENV
echo "FIRENAME1=x64" >> $GITHUB_ENV

# x86修改固件名显示内核
sed -i 's/IMG_PREFIX:=/IMG_PREFIX:=k$(LINUX_VERSION)-/g' include/image.mk
# x86使用6.6内核
sed -i 's/KERNEL_PATCHVER:=6.1/KERNEL_PATCHVER:=6.6/g' target/linux/x86/Makefile

# 首页显示编译时间
sed -i 's/OpenWrt/Bin AutoBuild '"$(date +%y.%m.%d)"' @ OpenWrt/g' package/lean/default-settings/files/zzz-default-settings

# 修改默认主题
sed -i 's/bootstrap/ifit/g' feeds/luci/collections/luci/Makefile

# 修改默认IP
sed -i 's/192.168.1.1/192.168.7.1/g' package/base-files/files/bin/config_generate

# 修改主机名
sed -i 's/OpenWrt/Bin-Lean/g' package/base-files/files/bin/config_generate
sed -i "/mac80211/a\sed -i '/luciversion/d' /usr/lib/lua/luci/version.lua" package/lean/default-settings/files/zzz-default-settings
sed -i '/version.lua/a\echo "luciversion = \\"Bin\\"\" >> /usr/lib/lua/luci/version.lua' package/lean/default-settings/files/zzz-default-settings

# 修改软件源
sed -i '/check_signature/d' package/system/opkg/Makefile
sed -i 's#downloads.openwrt.org#downloads.openwrt.org/snapshots#g' package/lean/default-settings/files/zzz-default-settings
sed -i '/openwrt_luci/d' package/lean/default-settings/files/zzz-default-settings
sed -i 's#mirrors.cloud.tencent.com/lede#ipk.ch89.cn/'"$FIRENAME1"'/bin#g' package/lean/default-settings/files/zzz-default-settings

# 修改zerotier到服务菜单栏
sed -i 's/\bvpn\b/services/g' feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua
sed -i 's/\bvpn\b/services/g' feeds/luci/applications/luci-app-zerotier/luasrc/view/zerotier/zerotier_status.htm

# x86显示CPU型号
sed -i "s#h=\${g}' - '#h=#g" package/lean/autocore/files/x86/autocore

msgid "Compile update"
msgstr "固件地址"
EOF

# 修改概览里时间显示为中文数字
sed -i 's/os.date()/os.date("%Y年%m月%d日") .. " " .. translate(os.date("%A")) .. " " .. os.date("%X")/g' package/lean/autocore/files/x86/index.htm

# 临时修复go版本,v2dat
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang
sed -i 's/CGO_ENABLED=0/CGO_ENABLED=1/g' feeds/packages/utils/v2dat/Makefile
