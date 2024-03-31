#!/usr/bin/env bash

{
    # installs NVM (Node Version Manager)
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

    # download and install latest available Node.js
    nvm install node
} | tee -a "$CONFIG_LOG"