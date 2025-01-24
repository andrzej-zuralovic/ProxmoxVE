#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: andzej-zuralovic
# License: MIT
# Source: https://it-tools.tech/

# Import Functions und Setup
source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

# Installing Dependencies with the 3 core dependencies (curl;sudo;mc)
msg_info "Installing Dependencies"
$STD apt-get install -y \
  curl \
  sudo \
  mc \
  nginx
msg_ok "Installed Dependencies"

# Setup App
msg_info "Setup ${APPLICATION}"
mkdir -p /opt/${APPLICATION}
cd /opt/${APPLICATION}
RELEASE=$(curl -s https://api.github.com/repos/CorentinTh/it-tools/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
ASSET_NAME="it-tools-${RELEASE#v}"
wget -q "https://github.com/CorentinTh/it-tools/releases/download/${RELEASE}/${ASSET_NAME}.zip"
unzip -q ${ASSET_NAME}.zip
mv dist/* /opt/${APPLICATION}
echo "${RELEASE}" >/opt/${APPLICATION}_version.txt
msg_ok "Setup ${APPLICATION}"

# Configure Service (NGINX)
msg_info "Configure Service"
cat <<EOF >/etc/nginx/sites-enabled/default
server {
    listen 80;
    server_name localhost;
    root /opt/$APPLICATION;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

systemctl reload nginx
msg_ok "Configured Service"

motd_ssh
customize

# Cleanup
msg_info "Cleaning up"
rm -rf "/otp/${APPLICATION}/${ASSET_NAME}.zip"
rm -rf "/opt/${APPLICATION}/dist"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"

motd_ssh
customize
