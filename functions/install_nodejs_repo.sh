#!/bin/bash

rpm_file=$(ls /etc/yum.repos.d/nodesource*.repo)
if [[ -z $rpm_file ]]; then
    echo "Nodesource not installed. Installing now..."
else
    echo "Nodesource was already installed. Removing and installing latest..."
    dnf -y remove nodesource-release-nodistro-1.noarch
    rm -fv /etc/yum.repos.d/nodesource*
    rm -fv /etc/pki/rpm-gpg/node*
    rm -fv /etc/pki/rpm-gpg/NODE*
fi
cd /etc/pki/rpm-gpg || mkdir -p /etc/pki/rpm-gpg ; cd /etc/pki/rpm-gpg || exit 1
wget https://rpm.nodesource.com/gpgkey/nodesource.gpg.key
update-crypto-policies --set DEFAULT:SHA1
rpm --import /etc/pki/rpm-gpg/nodesource.gpg.key
cd || exit 1
test_url="https://rpm.nodesource.com/pub_2VER.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm"
http_status=0
http_status_desired=200
ver=24
valid_url="https://rpm.nodesource.com/pub_20.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm"
while [[ $http_status -ne $http_status_desired ]]; do
    valid_url="${test_url/2VER/$ver}"
    http_status=$(curl -is "$valid_url" | head -n 1 | grep -o -E ' [0-9]+')
    export valid_url
    echo "$ver returned $http_status"
    if [[ $http_status -eq $http_status_desired ]]; then
        echo "
    FOUND: $valid_url
    Testing Repodata...
        "
        repodataurl=https://rpm.nodesource.com/pub_${ver}.x/nodistro/nodejs/x86_64/repodata/repomd.xml
        http_status=$(curl -is "$repodataurl" | head -n 1 | grep -o -E ' [0-9]+')
        echo "Repodata for Version ${ver}.x returned $http_status"
        if [[ $http_status -eq $http_status_desired ]]; then
            echo "
    Valid: $repodataurl
    Installing: $valid_url
            "
        fi
    fi
    ver=$((ver - 1))
done
dnf -y install "${valid_url}"