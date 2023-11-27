#!/bin/bash

# 修改内核
sed -i 's/PATCHVER:=*.*/PATCHVER:=6.1/g' target/linux/x86/Makefile

# luci-app-ssr-plus
#git clone --depth=1 https://github.com/fw876/helloworld.git package/helloworld

# luci-app-passwall2
echo "src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main" >> "feeds.conf.default"
echo "src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2.git;main" >> "feeds.conf.default"
#git clone https://github.com/xiaorouji/openwrt-passwall-packages package/passwall_packages
#git clone https://github.com/xiaorouji/openwrt-passwall2 package/passwall2

# luci-app-xray
#git clone https://github.com/yichya/luci-app-xray package/luci-app-xray
#git clone https://github.com/xiechangan123/luci-i18n-xray-zh-cn package/luci-i18n-xray-zh-cn
#git clone https://github.com/yichya/openwrt-xray package/openwrt-xray

# luci-app-alist网盘管理
git clone https://github.com/sbwml/luci-app-alist package/alist

# luci-theme-kucat
git clone -b js https://github.com/sirpdboy/luci-theme-kucat.git package/luci-theme-kucat
#sed -i '/set luci.main.mediaurlbase*/d' package/luci-theme-kucat/root/etc/uci-defaults/30_luci-kucat

# SmartDNS
#git clone --depth=1 https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
#git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns
