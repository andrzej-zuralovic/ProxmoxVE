#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/andrzej-zuralovic/ProxmoxVE/add-it-tools/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: andzej-zuralovic
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://it-tools.tech/

# App Default Values
APP="IT-TOOLS"
# Name of the app (e.g. Google, Adventurelog, Apache-Guacamole"
TAGS="it;tools"
# Tags for Proxmox VE, maximum 2 pcs., no spaces allowed, separated by a semicolon ; (e.g. database | adblock;dhcp)
var_cpu="1"
# Number of cores (1-X) (e.g. 4) - default are 2
var_ram="512"
# Amount of used RAM in MB (e.g. 2048 or 4096)
var_disk="2"
# Amount of used disk space in GB (e.g. 4 or 10)
var_os="debian"
# Default OS (e.g. debian, ubuntu, alpine)
var_version="12"
# Default OS version (e.g. 12 for debian, 24.04 for ubuntu, 3.20 for alpine)
var_unprivileged="1"
# 1 = unprivileged container, 0 = privileged container

# App Output & Base Settings
header_info "$APP"
base_settings

# Core
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  # Check if installation is present | -f for file, -d for folder
  if [[ ! -f "/opt/${APP}/index.html" ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  # Crawling the new version and checking whether an update is required
  RELEASE=$(curl -s https://api.github.com/repos/CorentinTh/it-tools/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
  if [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]] || [[ ! -f /opt/${APP}_version.txt ]]; then
    msg_info "Updating $APP"

    # Creating Backup
    msg_info "Creating Backup"
    tar -xzf "/opt/${APP}_backup_$(date +%F).tar.gz" -C /opt/${APP}
    msg_ok "Backup Created"

    # Execute Update
    msg_info "Updating $APP to v${RELEASE}"
    ASSET_NAME="it-tools-${RELEASE#v}"
    rm -rf /opt/${APP}/*
    cd /opt/${APP}
    wget -q "https://github.com/CorentinTh/it-tools/releases/download/${RELEASE}/${ASSET_NAME}.zip"
    unzip -q "${ASSET_NAME}.zip"
    mv dist/* /opt/${APP}
    msg_ok "Updated $APP to v${RELEASE}"

    # Cleaning up
    msg_info "Cleaning Up"
    rm -rf "/otp/${APP}/${ASSET_NAME}.zip"
    rm -rf "/opt/${APP}/dist"
    msg_ok "Cleanup Completed"

    # Last Action
    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Update Successful"
    exit

  else
    msg_ok "No update required. ${APP} is already at v${RELEASE}"
    exit
  fi
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:80${CL}"
