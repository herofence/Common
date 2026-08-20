#!/bin/bash

# Remove packages
#rm -rf feeds/packages/net/v2ray-geodata
#rm -rf feeds/luci/applications/luci-app-daed
rm -rf package/openwrt-clashoo

#去除自动升级
sed -i '/luci-app-attendedsysupgrade/d' feeds/luci/collections/luci/Makefile

# 添加源
#echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> "feeds.conf.default"

# Add packages
git clone --depth=1 https://github.com/ophub/luci-app-amlogic package/amlogic
git clone https://github.com/kenzok8/openwrt-clashoo.git package/openwrt-clashoo
#git clone  https://github.com/linkease/luci-app-linkease package/linkease
#git clone  https://github.com/gdy666/luci-app-lucky.git package/lucky
#git_sparse_clone main https://github.com/kenzok8/small-package luci-app-floatip floatip
#git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-app-onliner
#git_sparse_clone https://github.com/VIKINGYFY/packages luci-app-homeproxy
#git clone https://github.com/QiuSimons/luci-app-daed package/daed
git clone --depth=1 -b master https://github.com/vernesong/OpenClash.git package/luci-app-openclash

# 加入OpenClash核心
#chmod -R a+x $GITHUB_WORKSPACE/preset-clash-core.sh
#$GITHUB_WORKSPACE/N1/preset-clash-core.sh

echo "
# 插件
CONFIG_PACKAGE_luci-app-amlogic=y
CONFIG_PACKAGE_luci-app-openclash=y
CONFIG_PACKAGE_luci-app-clashoo=y
#CONFIG_PACKAGE_luci-app-nikki=y
" >> .config

# 修改默认IP
sed -i 's/192.168.1.1/192.168.2.254/g' package/base-files/files/bin/config_generate

# 修改默认主题
sed -i 's/luci-theme-design/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 修改主机名
sed -i 's/ImmortalWrt/OpenWrt/g' package/base-files/files/bin/config_generate
