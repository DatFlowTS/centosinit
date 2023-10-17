#!/bin/bash

{
    yum -y install wget curl dnf sqlite
    dnf -y install gcc-c++ make vim epel-release dnf-plugins-core cockpit
    dnf -y install https://pkgs.dyn.su/el9/base/x86_64/raven-release-1.0-4.el9.noarch.rpm
    dnf -y config-manager --set-enabled {raven,raven-extras,crb,epel,extras,plus}
    cd /etc/pki/rpm-gpg || mkdir -p /etc/pki/rpm-gpg ; cd /etc/pki/rpm_gpg || exit 1
    wget https://packages.endpointdev.com/endpoint-rpmsign-9.pub
    rpm --import endpoint-rpmsign-9.pub
    rpm -qi gpg-pubkey-4d996065 | gpg --show-keys --with-fingerprint
    cd || exit 1
    sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/install_nodejs_repo.sh)"
    dnf -y install https://packages.endpointdev.com/rhel/9/main/x86_64/endpoint-repo.noarch.rpm
    dnf clean all ; dnf -y upgrade --refresh ; dnf -y update ; dnf clean all
    dnf -y install nsolid || dnf -y install nodejs
    dnf -y install --skip-broken git cockpit-{packagekit,sosreport,storaged,networkmanager,selinux,kdump,navigator,podman}
    git clone https://github.com/skobyda/cockpit-certificates.git
    cd cockpit-certificates || exit 1
    make install
    cd || exit 1
    systemctl enable --now cockpit.socket && systemctl start cockpit.socket
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.rpm.sh | sudo bash
    curl -s https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch -o /usr/bin/neofetch
    chmod -v 555 /usr/bin/neofetch
    dnf -y install zsh speedtest google-authenticator
    npm i -g typescript pm2
    sed -i 's/bash/zsh/g' /etc/default/useradd
    usermod --shell /bin/zsh root
    cd ~ || exit 1
    sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/zsh/wheel.sh)"
} | tee -a $LOGFILE