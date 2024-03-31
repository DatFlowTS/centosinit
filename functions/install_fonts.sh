#!/bin/env bash

{
    echo "
--------------------------
--------------------------
Installing powerline fonts
--------------------------
    "
    git clone https://github.com/powerline/fonts.git --depth=1
    cd fonts || exit 1
    ./install.sh
    cd ..
    rm -rf fonts
    cp -afv $HOME/.local /etc/skel/
    touch .hushlogin
    touch /etc/skel/.hushlogin
}