#!/usr/bin/env bash

{
    rpm_file=$(ls /etc/yum.repos.d/*endpoint*.repo)
    if [[ -z $rpm_file ]]; then
        echo "Endpoint not installed. Installing now..."
    else
        echo "Endpoint was already installed. Removing and installing latest..."
        dnf -y remove endpoint-repo.noarch
        rm -fv /etc/yum.repos.d/*endpoint*
        rm -fv /etc/pki/rpm-gpg/*endpoint*
    fi
    cd /etc/pki/rpm-gpg || mkdir -p /etc/pki/rpm-gpg ; cd /etc/pki/rpm-gpg || exit 1
    wget "https://packages.endpointdev.com/endpoint-rpmsign-${distro_version}.pub"
    rpm --import "endpoint-rpmsign-${distro_version}.pub"
    dnf -y install "https://packages.endpointdev.com/rhel/${distro_version}/main/x86_64/endpoint-repo.noarch.rpm"
} | tee -a "$CONFIG_LOG"