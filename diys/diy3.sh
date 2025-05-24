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

##. 默认ip
#sed -i 's/*.*.*.*/192.168.2.1/g' package/base-files/files/bin/config_generate

# 修改密码
sed -i 's/root:::0:99999:7:::/root:$1$SOP5eWTA$fJV8ty3QohO0chErhlxCm1:18775:0:99999:7:::/g' package/base-files/files/etc/shadow

# 修复上移下移按钮翻译
sed -i 's/<%:Up%>/<%:Move up%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm
sed -i 's/<%:Down%>/<%:Move down%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm

# 修复procps-ng-top导致首页cpu使用率无法获取
sed -i 's#top -n1#\/bin\/busybox top -n1#g' feeds/luci/modules/luci-base/root/usr/share/rpcd/ucode/luci

# 修复编译时提示 freeswitch 缺少 libpcre 依赖
sed -i 's/+libpcre \\$/+libpcre2 \\/g' package/feeds/telephony/freeswitch/Makefile

# 替换udpxy为修改版，解决组播源数据有重复数据包导致的花屏和马赛克问题
#rm -rf feeds/packages/net/udpxy/Makefile
#curl -sfL https://raw.githubusercontent.com/lwb1978/OpenWrt-Actions/main/patch/udpxy/Makefile -o feeds/packages/net/udpxy/Makefile
rm -rf feeds/packages/net/udpxy/Makefile
cp -rf ${GITHUB_WORKSPACE}/patch/udpxy/Makefile feeds/packages/net/udpxy/
#rm -rf feeds/luci/applications/luci-app-udpxy/po
#cp -rf ${GITHUB_WORKSPACE}/patch/luci-app-udpxy/po feeds/luci/applications/luci-app-udpxy/po

# 精简 UPnP 菜单名称
sed -i 's#\"title\": \"UPnP IGD \& PCP/NAT-PMP\"#\"title\": \"UPnP\"#g' feeds/luci/applications/luci-app-upnp/root/usr/share/luci/menu.d/luci-app-upnp.json
# 移动 UPnP 到 “网络” 子菜单
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/root/usr/share/luci/menu.d/luci-app-upnp.json

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
sed -i 's/automount/luci-app-homeproxy luci-app-nikki luci-app-udpxy/g' target/linux/x86/Makefile
#sed -i 's/kmod-r8101 kmod-r8125 kmod-r8126 kmod-r8168 kmod-8139cp kmod-8139too kmod-fs-f2fs/kmod-fs-f2fs/g' target/linux/x86/Makefile

## 启用 eBPF 支持
mirror=raw.githubusercontent.com/sbwml/r4s_build_script/master
# bpf
echo '### BPF
CONFIG_DEVEL=y
CONFIG_BPF_TOOLCHAIN_HOST=y
# CONFIG_BPF_TOOLCHAIN_NONE is not set
CONFIG_KERNEL_BPF_EVENTS=y
CONFIG_KERNEL_CGROUP_BPF=y
CONFIG_KERNEL_DEBUG_INFO=y
CONFIG_KERNEL_DEBUG_INFO_BTF=y
# CONFIG_KERNEL_DEBUG_INFO_REDUCED is not set
CONFIG_KERNEL_MODULE_ALLOW_BTF_MISMATCH=y
CONFIG_KERNEL_XDP_SOCKETS=y

### BPF Kernel Modules
CONFIG_PACKAGE_kmod-sched-core=y
CONFIG_PACKAGE_kmod-sched-bpf=y
CONFIG_PACKAGE_kmod-xdp-sockets-diag=y
' >>  ./.config

./scripts/feeds update -a
./scripts/feeds install -a

echo "========================="
echo " DIY2 配置完成……"
