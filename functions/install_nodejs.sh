#!/usr/bin/env bash

# Define temporary directory and npm package list file
TMP_DIR="${HOME}/tmp"
NPM_LIST="$TMP_DIR/npm_packages.list"

# Get the current user
CURRENT_USER=$(whoami)

# Get current user's home directory (in case the user's environment was not loaded)
HOME_DIR=$(eval echo ~"$CURRENT_USER")

# Check if $TMP_DIR exists and creates it if not
cd "$TMP_DIR" || mkdir -p "$TMP_DIR"
if [ "$OLDPWD" != "$TMP_DIR" ]; then cd - || exit 1; fi

# Function to remove Node.js
remove_node() {
    # Check if Node.js is installed via nvm
    if type nvm >/dev/null 2>&1; then
        # Get the currently active Node.js version
        CURRENT_VERSION=$(nvm current)

        # Uninstall all installed Node.js versions except the currently active one
        for version in $(nvm ls --no-colors | grep -o -E 'v[0-9]+\.[0-9]+\.[0-9]+'); do
            if [ "$version" != "$CURRENT_VERSION" ]; then
                nvm uninstall "$version"
            fi
        done
    fi

    # Check if Node.js is installed via fnm
    if type fnm >/dev/null 2>&1; then
        for version in $(fnm list | grep -o -E 'v[0-9]+\.[0-9]+\.[0-9]+'); do
            fnm uninstall "$version"
        done
    fi

    # Check if Node.js is installed via brew
    if type brew >/dev/null 2>&1; then
        if brew list node &>/dev/null; then
            brew uninstall --force node
        fi
    fi

    # Check if Node.js is installed via docker
    if type docker >/dev/null 2>&1; then
        if docker images | grep node &>/dev/null; then
            docker rmi node
        fi
    fi

    # Check if Node.js is installed via package manager
    if type node >/dev/null 2>&1; then
        if [ "$CURRENT_USER" = "root" ]; then
            PACKAGE_COMMAND=$(bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/get_package_command.sh) remove)
            $PACKAGE_COMMAND nodejs
        else
            echo "You're not root! Skipping uninstall..."
        fi
    fi
}

# Function to preserve npm and pm2 settings
preserve_npm_pm2() {
    # Determine the npm command based on the current user
    case "$CURRENT_USER" in
    "root")
        NPM_CMD="npm list -g --depth=0"
        ;;
    *)
        NPM_CMD="npm list --depth=0"
        ;;
    esac

    # Check if Node.js is installed
    if type node >/dev/null 2>&1; then
        cd "$TMP_DIR" || mkdir -p "$TMP_DIR";cd "$TMP_DIR" || exit 1
        if [ ! -f "$NPM_LIST" ]; then touch "$NPM_LIST"; fi
        NODE_INSTALLED=true
        # Save the list of installed npm packages
        $NPM_CMD >"$NPM_LIST"
        # Save the pm2 process list if pm2 is installed
        if type pm2 >/dev/null 2>&1; then
            pm2 save
        fi
    else
        NODE_INSTALLED=false
    fi
    echo $NODE_INSTALLED
}

# Function to restore npm and pm2 settings
restore_npm_pm2() {
    # Determine the npm command based on the current user
    case "$CURRENT_USER" in
    "root")
        NPM_CMD="npm install -g"
        ;;
    *)
        NPM_CMD="npm install"
        ;;
    esac

    # Install the previously saved npm packages
    $NPM_CMD "$(cat "$NPM_LIST")"
    # Remove the saved npm package list
    rm -f "$NPM_LIST"
    # Restore the pm2 process list if pm2 is installed
    if type pm2 >/dev/null 2>&1; then pm2 resurrect; fi
}

# Function to remove nvm
remove_nvm() {
    # Unset environment variables
    unset NVM_DIR
    unset nvm

    # Remove nvm directory
    rm -rf "$HOME/.nvm"

    # Remove nvm lines from shell profile file
    if [ -f "$HOME/.bashrc" ]; then
        sed -i '/NVM_DIR/d' "$HOME/.bashrc"
    fi
    if [ -f "$HOME/.bash_profile" ]; then
        sed -i '/NVM_DIR/d' "$HOME/.bash_profile"
    fi
    if [ -f "$HOME/.zshrc" ]; then
        sed -i '/NVM_DIR/d' "$HOME/.zshrc"
    fi

    echo "nvm removed successfully."
}

# Function to update nvm
update_nvm() {
    # Get the latest release version of nvm
    NVM_LATEST=$(curl --silent "https://api.github.com/repos/nvm-sh/nvm/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

    # Get the currently installed version of nvm
    if type nvm >/dev/null 2>&1; then
        NVM_VERSION=$(nvm --version)
        # If the latest version is higher than the installed version, remove the installed version
        if [ "$NVM_VERSION" != "$NVM_LATEST" ]; then
            echo "Updating nvm from version $NVM_VERSION to $NVM_LATEST..."
            remove_nvm
        else
            echo "nvm is already up-to-date (version $NVM_VERSION)"
            return 0
        fi
    fi

    # Install nvm for the current user
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_LATEST/install.sh" | bash
    # shellcheck disable=SC1091
    source "$HOME/.nvm/nvm.sh"
    echo "nvm version $NVM_LATEST installed for the current user."
}

# Function to update Node.js
update_node() {
    remove_node
    update_nvm
    # Check if Node.js is installed via nvm
    if type nvm >/dev/null 2>&1; then
        # Get the currently active Node.js version
        CURRENT_VERSION=$(nvm current)
        # Uninstall all installed Node.js versions except the currently active one
        for version in $(nvm ls --no-colors | grep -o -E 'v[0-9]+\.[0-9]+\.[0-9]+'); do
            if [ "$version" != "$CURRENT_VERSION" ]; then
                nvm uninstall "$version"
            fi
        done
    fi
    nvm install node
    nvm uninstall "$CURRENT_VERSION"
}

loop_users() {
    GET_USERS=$(grep -vE '(/s?bin/(nologin|shutdown|sync|halt|false))' /etc/passwd | cut -d: -f1)
    for SOME_USER in $GET_USERS; do
        if [ "$SOME_USER" = "root" ]; then
            echo "Skipping root..."
        elif [ -d "$HOME_DIR" ] && [ "$HOME_DIR" != "/root" ]; then
            case "${1}" in
            "pre")
                # shellcheck disable=SC2016
                su "$SOME_USER" - -c '
NODE_INSTALLED=$(bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/install_nodejs.sh) preserve)
touch '"$HOME_DIR"'/tmp/NODE_INSTALLED;echo "$NODE_INSTALLED" > '"$HOME_DIR"'/tmp/NODE_INSTALLED
bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/install_nodejs.sh) remove
exit
                '
                ;;
            "post")
                # shellcheck disable=SC2016
                su "$SOME_USER" - -c '
bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/install_nodejs.sh) local 
NODE_INSTALLED=$(cat '"$HOME_DIR"'/tmp/NODE_INSTALLED)
if [ "NODE_INSTALLED" = "true" ]; then
    bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/install_nodejs.sh) restore
    rm -rf '"$HOME_DIR"'/tmp/NODE_INSTALLED
fi    
exit
            '
                ;;
            *)
                echo "invalid argument ${1}!"
                exit 1
                ;;
            esac
        else
            echo "User $SOME_USER doesn't have a home directory. Ignoring..."
        fi
    done
}

LOG_FILE=$(bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh) setup)
CONFIG_LOG=$(bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh) config)
bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/create_bashrc.sh)

{
    case "${1}" in
    "preserve")
        preserve_npm_pm2
        ;;
    "remove")
        remove_node
        remove_nvm
        ;;
    "restore")
        restore_npm_pm2
        ;;
    "global")
        if [ "$CURRENT_USER" = "root" ]; then
            NODE_INSTALLED="$(preserve_npm_pm2)"
            loop_users "pre"
            update_node
            if [ "$NODE_INSTALLED" = true ]; then restore_npm_pm2; fi
            loop_users "post"
        else
            echo "Must be root for global execution!"
            exit 1
        fi
        ;;
    "local")
        NODE_INSTALLED="$(preserve_npm_pm2)"
        update_node
        if [ "$NODE_INSTALLED" = true ]; then restore_npm_pm2; fi
        ;;
    *)
        echo "Invalid argument ${1}!"
        exit 1
        ;;
    esac
} | tee -a "$LOG_FILE" | tee -a "$CONFIG_LOG"
