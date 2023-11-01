#!/bin/bash

# 修改内核
sed -i 's/PATCHVER:=*.*/PATCHVER:=6.1/g' target/linux/x86/Makefile

# 修改include/target.mk
#sed -i "s/autocore/autocore-x86/" include/target.mk

# 修改target/linux/x86/Makefile
sed -i 's/automount/autocore default-settings-chn ipset luci luci-compat luci-app-udpxy luci-app-upnp/g' target/linux/x86/Makefile

# luci-app-ssr-plus
#git clone --depth=1 https://github.com/fw876/helloworld.git package/helloworld

# luci-app-passwall2
echo "src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main" >> "feeds.conf.default"
echo "src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2.git;main" >> "feeds.conf.default"

# luci-theme-kucat
echo 'src-git packages/luci-theme-kucat https://github.com/sirpdboy/luci-theme-kucat.git;js' >> feeds.conf.default
