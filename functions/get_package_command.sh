#!/bin/env bash

distro=$(bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/get_distro_infos.sh) base)
version_id=$(bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/get_distro_infos.sh) version)

case "${1}" in
"install")
    case "${distro}" in
    "rhel")
        if [ "$version_id" -gt 7 ]; then
            echo "dnf -y install"
        else
            echo "yum -y install"
        fi
        ;;
    "debian" | "ubuntu")
        echo "apt-get install -y"
        ;;
    "arch" | "manjaro")
        echo "pacman -S"
        ;;
    *)
        echo "Unsupported distribution for install operation"
        ;;
    esac
    ;;
"remove")
    case "${distro}" in
    "rhel")
        if [ "$version_id" -gt 7 ]; then
            echo "dnf -y remove"
        else
            echo "yum -y remove"
        fi
        ;;
    "debian" | "ubuntu")
        echo "apt-get purge -y"
        ;;
    "arch" | "manjaro")
        echo "pacman -R"
        ;;
    *)
        echo "Unsupported distribution for remove operation"
        ;;
    esac
    ;;
*)
    echo "Invalid operation. Please use 'install' or 'remove'"
    ;;
esac
