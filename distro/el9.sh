#!/bin/bash

yum -y install curl wget gcc-c++ make vim dnf epel-release dnf-plugins-core cockpit | tee -a $LOGFILE
dnf -y install --skip-broken cockpit-{packagekit,sosreport,storaged,networkmanager,selinux,kdump} | tee -a $LOGFILE
systemctl enable --now cockpit.socket && systemctl start cockpit.socket | tee -a $LOGFILE
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.rpm.sh | sudo bash >> $LOGFILE
dnf -y install https://pkgs.dyn.su/el9/base/x86_64/raven-release-1.0-4.el9.noarch.rpm | tee -a $LOGFILE
dnf -y config-manager --set-enabled {raven,raven-extras,crb,epel,extras,plus} | tee -a $LOGFILE
dnf -y upgrade --refresh  | tee -a $LOGFILE
curl -sL https://rpm.nodesource.com/setup_current.x | sudo -E bash - >> $LOGFILE
curl -s https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch -o /usr/bin/neofetch | tee -a $LOGFILE
chmod -v 555 /usr/bin/neofetch | tee -a $LOGFILE
dnf -y install git nodejs zsh speedtest | tee -a $LOGFILE
npm i -g typescript pm2 | tee -a $LOGFILE
sed -i 's/bash/zsh/g' /etc/default/useradd
usermod --shell /bin/zsh root
cd ~
sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/zsh/wheel.sh)"