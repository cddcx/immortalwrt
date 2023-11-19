#!/bin/bash

mkdir -p files/usr/share/singbox

GEOIP_URL="https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db"
GEOSITE_URL="https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db"

wget -qO- $GEOIP_URL > files/usr/share/singbox/geoip.db
wget -qO- $GEOSITE_URL > files/usr/share/singbox/geosite.db
