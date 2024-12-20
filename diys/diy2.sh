#!/bin/bash
#=================================================

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

function drop_package(){
	find package/ -follow -name $1 -not -path "package/custom/*" | xargs -rt rm -rf
}

function merge_feed(){
	./scripts/feeds update $1
	./scripts/feeds install -a -p $1
}

echo "开始 DIY2 配置……"
echo "========================="

#chmod +x ${GITHUB_WORKSPACE}/subscript.sh
#source ${GITHUB_WORKSPACE}/subscript.sh

# 修改内核
#sed -i 's/PATCHVER:=*.*/PATCHVER:=6.6/g' target/linux/x86/Makefile

# 修改密码
sed -i 's/root:::0:99999:7:::/root:$1$SOP5eWTA$fJV8ty3QohO0chErhlxCm1:18775:0:99999:7:::/g' package/base-files/files/etc/shadow

# 修复上移下移按钮翻译
sed -i 's/<%:Up%>/<%:Move up%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm
sed -i 's/<%:Down%>/<%:Move down%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm

# 修复procps-ng-top导致首页cpu使用率无法获取
sed -i 's#top -n1#\/bin\/busybox top -n1#g' feeds/luci/modules/luci-base/root/usr/share/rpcd/ucode/luci

# ppp - 2.5.0
rm -rf package/network/services/ppp
git clone https://github.com/sbwml/package_network_services_ppp package/network/services/ppp

# golang 1.22
rm -rf feeds/packages/lang/golang
git clone --depth=1 https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# 精简 UPnP 菜单名称
sed -i 's#\"title\": \"UPnP IGD \& PCP/NAT-PMP\"#\"title\": \"UPnP\"#g' feeds/luci/applications/luci-app-upnp/root/usr/share/luci/menu.d/luci-app-upnp.json
# 移动 UPnP 到 “网络” 子菜单
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/root/usr/share/luci/menu.d/luci-app-upnp.json

# 替换udpxy为修改版，解决组播源数据有重复数据包导致的花屏和马赛克问题
#rm -rf feeds/packages/net/udpxy/Makefile
#curl -sfL https://raw.githubusercontent.com/lwb1978/OpenWrt-Actions/main/patch/udpxy/Makefile -o feeds/packages/net/udpxy/Makefile
# 修改 udpxy 菜单名称为大写
#sed -i 's#\"title\": \"udpxy\"#\"title\": \"UDPXY\"#g' feeds/luci/applications/luci-app-udpxy/root/usr/share/luci/menu.d/luci-app-udpxy.json

# TTYD 自动登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config
# TTYD 更改
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i '3 a\\t\t"order": 50,' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g' feeds/packages/utils/ttyd/files/ttyd.init
sed -i 's/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/utils/ttyd/files/ttyd.init

# 修改include/target.mk
sed -i "s/DEFAULT_PACKAGES.router:=/DEFAULT_PACKAGES.router:=default-settings-chn luci-app-opkg luci-app-firewall /" include/target.mk
sed -i "s/kmod-nft-offload/kmod-nft-offload kmod-nft-tproxy/" include/target.mk

# 修改target/linux/x86/Makefile
sed -i 's/DEFAULT_PACKAGES += /DEFAULT_PACKAGES += luci-app-mihomo luci-app-upnp luci-app-udpxy luci-app-passwall2 /g' target/linux/x86/Makefil

## 删除软件
rm -rf feeds/luci/applications/luci-app-adguardhome
rm -rf feeds/packages/net/adguardhome
#rm -rf feeds/luci/themes/luci-theme-bootstrap
rm -rf feeds/luci/applications/luci-app-alist
rm -rf feeds/packages/net/alist
rm -rf feeds/luci/applications/{luci-app-v2raya,luci-app-shadowsocks-libev}
rm -rf feeds/packages/net/{v2raya,microsocks,shadowsocks-libev}}

## 启用 eBPF 支持
mirror=raw.githubusercontent.com/sbwml/r4s_build_script/master
# bpf
curl -s https://$mirror/openwrt/generic/config-bpf >> .config
# kselftests-bpf
curl -s https://$mirror/openwrt/patch/packages-patches/kselftests-bpf/Makefile > package/devel/kselftests-bpf/Makefile
# BTF: fix failed to validate module
curl -s https://$mirror/openwrt/patch/generic-24.10/0006-kernel-add-MODULE_ALLOW_BTF_MISMATCH-option.patch | patch -p1

# luci-app-daed
rm -rf feeds/luci/applications/luci-app-daed
rm -rf feeds/packages/net/daed
git clone https://github.com/QiuSimons/luci-app-daed package/dae
# 拷贝自定义文件
#if [ -n "$(ls -A "${GITHUB_WORKSPACE}/immortalwrt/diy" 2>/dev/null)" ]; then
	#cp -Rf ${GITHUB_WORKSPACE}/immortalwrt/diy/* .
#fi

./scripts/feeds update -a
./scripts/feeds install -a

echo "========================="
echo " DIY2 配置完成……"
