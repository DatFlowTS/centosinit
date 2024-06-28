#!/usr/bin/env bash

LOG_FILE=$(bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh) setup)
CONFIG_LOG=$(bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh) config)

{
    yum -y install wget curl dnf sqlite --allowerasing
    dnf -y install gcc-c++ make vim dnf-plugins-core cockpit --allowerasing
    sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/install_nodejs.sh)"
    sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/install_microsoft_repos.sh)"
    dnf clean all ; dnf -y upgrade --refresh ; dnf -y update
    dnf -y install --skip-broken git cockpit cockpit-{packagekit,sosreport,storaged,networkmanager,selinux,kdump,navigator,podman} --allowerasing
    systemctl enable --now cockpit.socket && systemctl start cockpit.socket
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.rpm.sh | sudo bash
    curl -s https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch -o /usr/bin/neofetch
    chmod -v 555 /usr/bin/neofetch
    dnf -y install zsh speedtest google-authenticator
    npm i -g typescript pm2
    sed -i 's/bash/zsh/g' /etc/default/useradd
    usermod --shell /bin/zsh root
    cd ~ || exit 1
    sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/zsh_setup.sh)"
} | tee -a "$LOG_FILE" | tee -a "$CONFIG_LOG"
