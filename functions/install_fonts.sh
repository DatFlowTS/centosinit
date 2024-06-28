#!/bin/env bash

LOG_FILE=$(bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh) setup)
CONFIG_LOG=$(bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh) config)

{
    echo "
--------------------------
--------------------------
Installing MesloLGS NF fonts
--------------------------
    "
    
    # Define the target directory
    TARGET_DIR="/usr/local/share/fonts/m"
    
    # Create the target directory if it doesn't exist
    cd "$TARGET_DIR" || sudo mkdir -vp "$TARGET_DIR" || exit 1
    
    # Download the .ttf files
    sudo wget -P "$TARGET_DIR" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    sudo wget -P "$TARGET_DIR" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    sudo wget -P "$TARGET_DIR" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    sudo wget -P "$TARGET_DIR" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
    
    # Update the font cache
    sudo fc-cache -f -v
    
} | tee -a "$LOG_FILE" | tee -a "$CONFIG_LOG"