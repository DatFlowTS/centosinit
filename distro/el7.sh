#!/usr/bin/env bash

LOG_FILE=$(bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh) setup)
CONFIG_LOG=$(bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh) config)

{
    yum -y install wget curl dnf
    dnf -y install gettext make gcc-c++ make vim epel-release dnf-plugins-core cockpit
    bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/install_45drives_repo.sh)
    dnf -y install cockpit-{packagekit,sosreport,storaged,networkmanager,selinux,kdump,navigator}
    systemctl enable --now cockpit.socket && systemctl start cockpit.socket
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.rpm.sh | sudo bash
    dnf -y config-manager --set-enabled {powertools,epel,extras,plus}
    dnf -y upgrade --refresh
    bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/install_nodejs.sh)
    bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/install_endpoint_repo.sh)
    curl -s https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch -o /usr/bin/neofetch
    chmod -v 555 /usr/bin/neofetch
    dnf -y install git nodejs zsh speedtest google-authenticator
    npm i -g typescript pm2
    sed -i 's/bash/zsh/g' /etc/default/useradd
    usermod --shell /bin/zsh root
    cd ~ || exit 1
    bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/zsh_setup.sh)
} | tee -a "$LOG_FILE" | tee -a "$CONFIG_LOG"