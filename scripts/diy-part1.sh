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
git clone --depth=1 https://github.com/vernesong/OpenClash.git package/luci-app-openclash
git clone https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall
git clone https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwal
popd

# add luci-app-mosdns
rm -rf feeds/packages/net/v2ray-geodata
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# ===== 修复 dockerd 编译问题 =====
if [ -d "feeds/packages/utils/dockerd" ]; then
    echo "修复 dockerd 编译问题..."
    cd feeds/packages/utils/dockerd
    
    # 尝试回退到稳定版本
    if git fetch --tags 2>/dev/null && git checkout v27.0.3 -- . 2>/dev/null; then
        echo "成功回退 dockerd 到 v27.0.3"
    else
        echo "无法回退 dockerd 版本，修补 Makefile..."
        # 备份原文件
        cp Makefile Makefile.bak
        
        # 注释掉有问题的复制命令
        sed -i '/cp.*bundles\/binary-daemon/s/^/#/' Makefile
        
        # 添加安全的复制命令
        sed -i '/#cp.*bundles\/binary-daemon/a\	cp -r $$(DOCKER_BUILD_DIR)/bundles/binary-daemon/* $(1)/usr/bin/ 2>/dev/null || true' Makefile
        
        echo "Makefile 修补完成"
    fi
    cd -
fi
# ===== 修复结束 =====

# 更改默认主题
if [ -f "./feeds/luci/collections/luci/Makefile" ]; then
    sed -i "s/luci-theme-bootstrap/luci-theme-argon/g" ./feeds/luci/collections/luci/Makefile
fi

# x86 型号只显示 CPU 型号
if [ -f "package/immortalwrt/autocore/files/x86/autocore" ]; then
    sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/immortalwrt/autocore/files/x86/autocore
elif [ -f "package/lean/autocore/files/x86/autocore" ]; then
    sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore
fi

# 修改本地时间格式
find package/ -path "*/autocore/files/*/index.htm" -exec sed -i 's#os.date()#os.date("%Y-%m-%d %H:%M:%S") .. " " .. translate(os.date("%A"))#g' {} \; 2>/dev/null
find feeds/luci/ -path "*/system.lua" -exec sed -i 's/os.date("%c")/os.date("%Y-%m-%d %H:%M:%S")/g' {} \; 2>/dev/null

# 最大连接数修改为65535
if [ -f "package/base-files/files/etc/sysctl.conf" ]; then
    sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf
fi

# 修改版本为编译日期
date_version=$(date +"%y.%m.%d")
if [ -f "package/immortalwrt/default-settings/files/zzz-default-settings" ]; then
    orig_version=$(cat "package/immortalwrt/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
    sed -i "s/${orig_version}/R${date_version} by herofence/g" package/immortalwrt/default-settings/files/zzz-default-settings
elif [ -f "package/lean/default-settings/files/zzz-default-settings" ]; then
    orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
    sed -i "s/${orig_version}/R${date_version} by herofence/g" package/lean/default-settings/files/zzz-default-settings
fi

# 取消主题默认设置
find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \; 2>/dev/null

# 修正部分从第三方仓库拉取的软件 Makefile 路径问题
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {} 2>/dev/null
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {} 2>/dev/null
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHREPO/PKG_SOURCE_URL:=https:\/\/github.com/g' {} 2>/dev/null
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHCODELOAD/PKG_SOURCE_URL:=https:\/\/codeload.github.com/g' {} 2>/dev/null

echo "脚本执行完成"
