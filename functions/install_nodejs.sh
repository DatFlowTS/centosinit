#!/usr/bin/env bash

LOG_FILE=$(sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh)" 'setup')
CONFIG_LOG=$(sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh)" 'config')

sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/create_bashrc.sh)"
{
    # installs NVM (Node Version Manager)
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    
    # shellcheck source=/dev/null
    source "$HOME/.bashrc"
    
    # download and install latest available Node.js
    nvm install node
    
} | tee -a "$LOG_FILE" | tee -a "$CONFIG_LOG"