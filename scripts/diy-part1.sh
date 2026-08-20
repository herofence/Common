#!/bin/bash

# 1. 修改默认IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# 2. 设置 Git 使用 token 认证（如果存在）
if [ -n "${GITHUB_TOKEN}" ]; then
    git config --global url."https://oauth2:${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"
fi

# 3. 清理冲突的主题和应用
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/packages/net/v2ray-geodata

# 4. 克隆第三方插件包到 package/community 目录
mkdir -p package/community
pushd package/community

# 主题与常用应用
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config
git clone --depth=1 https://github.com/y9858/luci-theme-opentomcat
git clone --depth=1 https://github.com/lisaac/luci-app-diskman
git clone --depth=1 https://github.com/gdy666/luci-app-lucky
git clone --depth=1 https://github.com/sirpdboy/netspeedtest
git clone --depth=1 https://github.com/lmq8267/luci-app-vnt
git clone --depth=1 https://github.com/EasyTier/luci-app-easytier
git clone --depth=1 -b openwrt-18.06 https://github.com/tty228/luci-app-wechatpush
git clone --depth=1 https://github.com/ilxp/luci-app-ikoolproxy
git clone --depth=1 https://github.com/esirplayground/luci-app-poweroff
git clone --depth=1 https://github.com/Jason6111/luci-app-netdata

# SmartDNS (保留单个官方推荐源)
git clone --depth=1 https://github.com/pymumu/luci-app-smartdns

# OpenClash
git clone --depth=1 https://github.com/vernesong/OpenClash.git

popd

# 5. 更改默认主题为 Argon
sed -i 's/luci-theme-design/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 6. x86 型号只显示 CPU 型号
if [ -f "package/immortalwrt/autocore/files/x86/autocore" ]; then
    sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/immortalwrt/autocore/files/x86/autocore
elif [ -f "package/lean/autocore/files/x86/autocore" ]; then
    sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore
fi

# 7. 修改本地时间格式
find package/ -path "*/autocore/files/*/index.htm" -exec sed -i 's#os.date()#os.date("%Y-%m-%d %H:%M:%S") .. " " .. translate(os.date("%A"))#g' {} \; 2>/dev/null
find feeds/luci/ -path "*/system.lua" -exec sed -i 's/os.date("%c")/os.date("%Y-%m-%d %H:%M:%S")/g' {} \; 2>/dev/null

# 8. 最大连接数修改为 65535
if [ -f "package/base-files/files/etc/sysctl.conf" ]; then
    sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf
fi

# 9. 修改版本号展示
date_version=$(date +"%y.%m.%d")
if [ -f "package/immortalwrt/default-settings/files/zzz-default-settings" ]; then
    orig_version=$(cat "package/immortalwrt/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
    sed -i "s/${orig_version}/R${date_version} by herofence/g" package/immortalwrt/default-settings/files/zzz-default-settings
elif [ -f "package/lean/default-settings/files/zzz-default-settings" ]; then
    orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
    sed -i "s/${orig_version}/R${date_version} by herofence/g" package/lean/default-settings/files/zzz-default-settings
fi

# 10. 取消主题默认配置覆盖
find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \; 2>/dev/null

echo "脚本执行完成"
