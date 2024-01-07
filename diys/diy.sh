#!/bin/bash

# 修改内核
sed -i 's/PATCHVER:=*.*/PATCHVER:=6.1/g' target/linux/x86/Makefile

# luci-app-ssr-plus
#git clone --depth=1 https://github.com/fw876/helloworld.git package/helloworld

## default-settings
#mkdir -p package/emortal/default-settings
#git_clone_path master https://github.com/immortalwrt/immortalwrt package/emortal/default-settings
#rm -rf package/emortal/default-settings
#git clone https://github.com/cddcx/default-settings.git package/emortal/default-settings

## luci-app-passwall2
#git_clone_path main https://github.com/xiaorouji/openwrt-passwall2 luci-app-passwall2
#cp -rf luci-app-passwall2 package/luci-app-passwall2
#rm -rf luci-app-passwall2
svn checkout https://github.com/xiaorouji/openwrt-passwall2/trunk/luci-app-passwall2 package/luci-app-passwall2
git clone https://github.com/xiaorouji/openwrt-passwall-packages package/passwall

# luci-app-xray
#git clone https://github.com/yichya/luci-app-xray package/luci-app-xray
#git clone https://github.com/xiechangan123/luci-i18n-xray-zh-cn package/luci-i18n-xray-zh-cn
#git clone https://github.com/yichya/openwrt-xray package/openwrt-xray

# luci-app-alist网盘管理
#git clone https://github.com/sbwml/luci-app-alist package/alist

# luci-theme-kucat
#git clone -b js https://github.com/sirpdboy/luci-theme-kucat.git package/luci-theme-kucat
#sed -i '/set luci.main.mediaurlbase*/d' package/luci-theme-kucat/root/etc/uci-defaults/30_luci-kucat

# SmartDNS
#git clone --depth=1 https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
#git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns
