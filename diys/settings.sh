#!/bin/bash

# 取消主题默认设置
find feeds/luci/themes/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase*/d' {} \;
#find feeds/luci/themes/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set_opt main.mediaurlbase*/d' {} \;
#find feeds/luci/collections/*/* -type f -name 'Makefile' -print -exec sed -i 's/luci-theme-bootstrap/luci-theme-kucat/g' {} \;

#sed -i '/set_opt main.mediaurlbase*/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap
#sed -i '/set luci.main.mediaurlbase*/d' feeds/luci/themes/luci-theme-argon/root/etc/uci-defaults/30_luci-theme-argon
#sed -i 's/luci-app-attendedsysupgrade/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
#sed -i 's/luci-theme-bootstrap/luci-theme-kucat/g' feeds/luci/collections/luci-nginx/Makefile
#sed -i 's/luci-theme-bootstrap/luci-theme-kucat/g' feeds/luci/collections/luci-ssl-nginx/Makefile
#sed -i 's/luci-theme-bootstrap/luci-theme-kucat/g' feeds/luci/collections/luci-light/Makefile

# 修改密码
sed -i 's/root:::0:99999:7:::/root:$1$SOP5eWTA$fJV8ty3QohO0chErhlxCm1:18775:0:99999:7:::/g' package/base-files/files/etc/shadow

# TTYD 自动登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config
# TTYD 更改
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i '3 a\\t\t"order": 50,' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g' feeds/packages/utils/ttyd/files/ttyd.init
sed -i 's/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/utils/ttyd/files/ttyd.init

## 删除软件
rm -rf feeds/luci/applications/luci-app-adguardhome
rm -rf feeds/packages/net/adguardhome
#rm -rf feeds/luci/themes/luci-theme-bootstrap
rm -rf feeds/luci/applications/luci-app-alist
rm -rf feeds/packages/net/alist
rm -rf feeds/luci/applications/luci-app-passwall
#rm -rf feeds/luci/applications/luci-app-smartdns
#rm -rf feeds/packages/net/smartdns
#rm -rf feeds/luci/applications/luci-app-ssr-plus

# 修改include/target.mk
sed -i "s/DEFAULT_PACKAGES.router:=/DEFAULT_PACKAGES.router:=default-settings-chn luci-app-opkg luci-app-firewall /" include/target.mk
sed -i "s/kmod-nft-offload/kmod-nft-offload kmod-nft-tproxy/" include/target.mk

# 修改target/linux/x86/Makefile
#sed -i 's/automount/default-settings-chn ipset luci luci-compat luci-app-filetransfer luci-app-passwall2 luci-app-ttyd luci-app-udpxy/g' target/linux/x86/Makefile
sed -i 's/automount/automount luci-app-diskman luci-app-dockerman luci-app-passwall2 luci-app-ttyd luci-app-udpxy/g' target/linux/x86/Makefile

#exit 0
