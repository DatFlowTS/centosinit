#!/usr/bin/env bash

LOG_FILE=$(sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh) setup")
CONFIG_LOG=$(sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh) config")

{
    dnf -y install breeze-gtk-common
    dnf -y groupinstall --allowerasing --best --skip-broken "KDE Plasma Workspaces" "base-x"
    echo "exec /usr/bin/startkde" >> ~/.xinitrc
    echo "exec /usr/bin/startkde" >> /etc/skel/.xinitrc
    systemctl set-default graphical.target
    dnf -y install yakuake
    read -p "Enable VNC Access on Port 5901 for $NEWUSER? (Y/N, default N) => " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        dnf -y install tigervnc-server
        cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service
        echo ":1=$NEWUSER" >> /etc/tigervnc/vncserver.users
        firewall-cmd --add-service=vnc-server
        firewall-cmd --permanent --add-service=vnc-server
        firewall-cmd --reload
        systemctl daemon-reload
        systemctl enable --now vncserver@:1.service
        echo '#######################################################'
        echo '#######################################################'
        echo '#######################################################'
        echo
        echo "VNC-Server and Service is enabled for $NEWUSER"
        echo "don't forget to set passwd and vncpasswd for that user"
        echo
        echo '#######################################################'
        echo '#######################################################'
        echo '#######################################################'
    fi
} | tee -a "$LOG_FILE" | tee -a "$CONFIG_LOG"