# 拉取仓库文件夹
function merge_package() {
	# 参数1是分支名,参数2是库地址,参数3是所有文件下载到指定路径。
	# 同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开。
	# 示例:
	# merge_package master https://github.com/WYC-2020/openwrt-packages package/openwrt-packages luci-app-eqos luci-app-openclash luci-app-ddnsto ddnsto 
	# merge_package master https://github.com/lisaac/luci-app-dockerman package/lean applications/luci-app-dockerman
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
	# 使用循环逐个移动文件夹
	for folder in "$@"; do
		mv -f "$folder" "$rootdir/$localdir"
	done
	cd "$rootdir"
}

# 移除要替换的包
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/msd_lite
rm -rf feeds/packages/net/smartdns
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/luci/applications/luci-app-netdata
rm -rf feeds/luci/applications/luci-app-pushbot
rm -rf feeds/luci/applications/luci-app-dockerman
rm -rf feeds/luci/applications/luci-app-diskman

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
#mosdns
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns.git ./luci-app-mosdns
# 主题
git clone --depth=1 https://github.com/kiddin9/luci-theme-edge.git ./luci-theme-edge
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git ./luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config.git ./luci-app-argon-config
git clone https://github.com/y9858/luci-theme-opentomcat.git ./luci-theme-opentomcat
# smartdns
git clone --depth=1 -b lede https://github.com/pymumu/luci-app-smartdns.git ./luci-app-smartdns
git clone --depth=1 https://github.com/pymumu/openwrt-smartdns.git ./smartdns
# diskman
git clone https://github.com/lisaac/luci-app-diskman.git ./applications/luci-app-diskman
# dockerman
git clone https://github.com/WYC-2020/luci-app-dockerman.git ./applications/luci-app-dockerman
# lucky
git clone https://github.com/gdy666/luci-app-lucky.git ./lucky
# istore
git clone --depth=1 https://github.com/linkease/istore.git ./istore
git clone --depth=1 https://github.com/linkease/nas-packages.git ./nas-packages
git clone --depth=1 https://github.com/linkease/nas-packages-luci.git ./nas-packages-luci
# 内网测速
git clone https://github.com/sirpdboy/netspeedtest.git ./netspeedtest
# 应用过滤
git clone https://github.com/destan19/OpenAppFilter.git ./OpenAppFilter

#其它
git clone --depth=1 -b openwrt-18.06 https://github.com/tty228/luci-app-wechatpush.git ./luci-app-serverchan
git clone --depth=1 https://github.com/ilxp/luci-app-ikoolproxy.git ./luci-app-ikoolproxy
git clone --depth=1 https://github.com/esirplayground/luci-app-poweroff.git ./luci-app-poweroff
git clone --depth=1 https://github.com/Jason6111/luci-app-netdata.git ./luci-app-netdata

# 科学上网插件
git clone https://github.com/xiaorouji/openwrt-passwall-packages.git ./openwrt-passwall
git clone https://github.com/xiaorouji/openwrt-passwall.git ./luci-app-passwall
