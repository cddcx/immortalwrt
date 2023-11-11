#!/bin/bash

# 修改默认主题
sed -i '/set luci.main.mediaurlbase*/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap
#sed -i '/set luci.main.mediaurlbase*/d' feeds/luci/themes/luci-theme-argon/root/etc/uci-defaults/30_luci-theme-argon
sed -i 's/luci-app-attendedsysupgrade/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci-nginx/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci-ssl-nginx/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci-light/Makefile

# 修改密码
sed -i 's/root:::0:99999:7:::/root:$1$SOP5eWTA$fJV8ty3QohO0chErhlxCm1:18775:0:99999:7:::/g' package/base-files/files/etc/shadow

## 删除软件
#rm -rf feeds/luci/applications/luci-app-adguardhome
#rm -rf feeds/packages/net/adguardhome
rm -rf feeds/luci/applications/luci-app-alist
rm -rf feeds/packages/net/alist
rm -rf feeds/luci/applications/luci-app-passwall
#rm -rf feeds/luci/applications/luci-app-smartdns
#rm -rf feeds/packages/net/smartdns
#rm -rf feeds/luci/applications/luci-app-ssr-plus

exit 0
