#!/bin/bash

echo "开始 DIY1 配置……"
echo "========================="

# luci-app-homeproxy
git clone https://github.com/immortalwrt/homeproxy package/luci-app-homeproxy           ####### homeproxy的默认版本(二选一) 
#git clone -b dev https://github.com/immortalwrt/homeproxy package/luci-app-homeproxy
#merge_package v5 https://github.com/sbwml/openwrt_helloworld  package/luci-app-homeproxy chinadns-ng sing-box
sed -i "s@ImmortalWrt@OpenWrt@g" package/luci-app-homeproxy/po/zh_Hans/homeproxy.po
sed -i "s@ImmortalWrt proxy@OpenWrt proxy@g" package/luci-app-homeproxy/htdocs/luci-static/resources/view/homeproxy/{client.js,server.js}

## luci-app-passwall
#merge_package main https://github.com/xiaorouji/openwrt-passwall package luci-app-passwall

# luci-app-nikki
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> "feeds.conf.default"

# bpf - add host clang-15/18/20 support
sed -i 's/clang-13/clang-15 clang-18 clang-20/g' include/bpf.mk

# luci-theme-kucat
#git clone -b js https://github.com/sirpdboy/luci-theme-kucat.git package/luci-theme-kucat
#sed -i '/set luci.main.mediaurlbase*/d' package/luci-theme-kucat/root/etc/uci-defaults/30_luci-kucat

# SmartDNS
#git clone --depth=1 https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
#git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns

echo "========================="
echo " DIY1 配置完成……"
