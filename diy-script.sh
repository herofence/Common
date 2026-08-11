#!/bin/bash

# 将默认IP 192.168.1.1 保持为 ImmortalWrt 默认
# sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# 更改boot分区大小为1M (x86平台)
sed -i 's/256/1024/g' target/linux/x86/image/Makefile

# 更改默认 Shell 为 zsh
sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# 修改默认时区
CFG_FILE="package/base-files/files/bin/config_generate"
sed -i "s/timezone='.*'/timezone='CST-8'/g" $CFG_FILE
sed -i "/timezone='.*'/a\\\t\t\tset system.@system[-1].zonename='Asia/Shanghai'" $CFG_FILE

# 拉取仓库文件夹
function merge_package() {
	# 参数1是分支名,参数2是库地址,参数3是所有文件下载到指定路径。
	# 同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开。
	if [[ $# -lt 3 ]]; then
		echo "Syntax error: [$#] [$*]" >&2
		return 1
	fi
	trap 'rm -rf "$tmpdir"' EXIT
	branch="$1" curl="$2" target_dir="$3" && shift 3
	rootdir="$PWD"
	localdir="$target_dir"
	[ -d "$localdir" ] || mkdir -p "$localdir"
	tmpdir="$(mktemp -d)" || exit 1
	git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$curl" "$tmpdir"
	cd "$tmpdir"
	git sparse-checkout init --cone
	git sparse-checkout set "$@"
	for folder in "$@"; do
		mv -f "$folder" "$rootdir/$localdir"
	done
	cd "$rootdir"
}

# 移除要替换的包 (适配 ImmortalWrt 路径)
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/smartdns
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/luci/applications/luci-app-netdata
rm -rf feeds/luci/applications/luci-app-pushbot

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# 添加额外插件
# mosdns - 使用 sbwml 版本，支持最新 ImmortalWrt
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns package/luci-app-mosdns

# 主题
git clone https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
git clone https://github.com/y9858/luci-theme-opentomcat package/luci-theme-opentomcat

# smartdns - 使用主分支适配 ImmortalWrt
git clone --depth=1 https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns

# diskman
git clone https://github.com/lisaac/luci-app-diskman package/applications/luci-app-diskman

# lucky
git clone https://github.com/gdy666/luci-app-lucky.git package/lucky

# istore
git clone --depth=1 https://github.com/linkease/istore package/istore
git clone --depth=1 https://github.com/linkease/nas-packages package/nas-packages
git clone --depth=1 https://github.com/linkease/nas-packages-luci package/nas-packages-luci

# 内网测速
git clone https://github.com/sirpdboy/netspeedtest.git package/netspeedtest

# 应用过滤
# git clone --depth=1 https://github.com/destan19/OpenAppFilter package/OpenAppFilter

# VNT
git clone https://github.com/lmq8267/luci-app-vnt.git package/vnt
git clone https://github.com/cg8-5712/vnt.git package/vnt

# EasyTier
git clone --depth=1 https://github.com/EasyTier/luci-app-easytier package/luci-app-easytier

# tailscale
# git clone https://github.com/asvow/luci-app-tailscale package/luci-app-tailscale

# 其它
git clone --depth=1 -b openwrt-18.06 https://github.com/tty228/luci-app-wechatpush package/luci-app-serverchan
git clone --depth=1 https://github.com/ilxp/luci-app-ikoolproxy package/luci-app-ikoolproxy
git clone --depth=1 https://github.com/esirplayground/luci-app-poweroff package/luci-app-poweroff
git clone --depth=1 https://github.com/Jason6111/luci-app-netdata package/luci-app-netdata
git_sparse_clone main https://github.com/Lienol/openwrt-package luci-app-filebrowser luci-app-ssr-mudb-server
git_sparse_clone openwrt-18.06 https://github.com/immortalwrt/luci applications/luci-app-eqos

# 科学上网插件
git clone --depth=1 https://github.com/vernesong/OpenClash.git package/luci-app-openclash
git clone https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall
git clone https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall

# 更改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-argon/g" ./feeds/luci/collections/luci/Makefile

# x86 型号只显示 CPU 型号 (适配 ImmortalWrt 路径)
# ImmortalWrt 可能在 package/immortalwrt/autocore 或 package/lean/autocore
if [ -d "package/immortalwrt/autocore" ]; then
    sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/immortalwrt/autocore/files/x86/autocore 2>/dev/null || true
elif [ -d "package/lean/autocore" ]; then
    sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore 2>/dev/null || true
fi

# 修改本地时间格式 (适配 ImmortalWrt 路径)
if [ -d "package/immortalwrt/autocore" ]; then
    sed -i 's#os.date()#os.date("%Y-%m-%d %H:%M:%S") .. " " .. translate(os.date("%A"))#g' package/immortalwrt/autocore/files/*/index.htm 2>/dev/null || true
elif [ -d "package/lean/autocore" ]; then
    sed -i 's#os.date()#os.date("%Y-%m-%d %H:%M:%S") .. " " .. translate(os.date("%A"))#g' package/lean/autocore/files/*/index.htm 2>/dev/null || true
fi
sed -i 's/os.date("%c")/os.date("%Y-%m-%d %H:%M:%S")/g' feeds/luci/modules/luci-mod-admin-mini/luasrc/controller/mini/system.lua

# 最大连接数修改为65535
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf

# 修改版本为编译日期 (适配 ImmortalWrt 默认设置路径)
if [ -f "package/immortalwrt/default-settings/files/zzz-default-settings" ]; then
    SETTINGS_FILE="package/immortalwrt/default-settings/files/zzz-default-settings"
elif [ -f "package/lean/default-settings/files/zzz-default-settings" ]; then
    SETTINGS_FILE="package/lean/default-settings/files/zzz-default-settings"
fi

if [ -n "$SETTINGS_FILE" ] && [ -f "$SETTINGS_FILE" ]; then
    date_version=$(date +"%y.%m.%d")
    orig_version=$(cat "$SETTINGS_FILE" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
    if [ -n "$orig_version" ]; then
        sed -i "s/${orig_version}/R${date_version} by herofence/g" "$SETTINGS_FILE"
    fi
fi

# 修复 hostapd 报错 (如果补丁文件存在)
if [ -f "$GITHUB_WORKSPACE/scripts/011-fix-mbo-modules-build.patch" ]; then
    cp -f $GITHUB_WORKSPACE/scripts/011-fix-mbo-modules-build.patch package/network/services/hostapd/patches/011-fix-mbo-modules-build.patch 2>/dev/null || true
fi

# 修正部分从第三方仓库拉取的软件 Makefile 路径问题
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {} 2>/dev/null || true
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {} 2>/dev/null || true
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHREPO/PKG_SOURCE_URL:=https:\/\/github.com/g' {} 2>/dev/null || true
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHCODELOAD/PKG_SOURCE_URL:=https:\/\/codeload.github.com/g' {} 2>/dev/null || true

# 取消主题默认设置
find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \; 2>/dev/null || true

./scripts/feeds update -a
./scripts/feeds install -a
echo "=== 已安装的包数量 ==="
find package/ -name "Makefile" | wc -l
