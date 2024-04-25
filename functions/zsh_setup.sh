#!/usr/bin/env bash

LOG_FILE=$(sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh)" 'setup')
CONFIG_LOG=$(sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh)" 'config')

{
    echo "Preparing to set up OhMyZSH...
    --------------------------"
    rm -rfv "$HOME"/.*ssh* "$HOME"/.*zsh* /etc/skel/.*ssh* /etc/skel/.*zsh*
    echo "
--------------------------
Running OhMyZSH installer:
--------------------------
--------------------------
    "
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    sed -i 's/robbyrussell/powerlevel10k\/powerlevel10k/g' "$HOME"/.zshrc
    # shellcheck disable=SC2016
    sed -i 's/\/root/\$HOME/g' "$HOME"/.zshrc
    git clone https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
    git clone https://github.com/Pilaton/OhMyZsh-full-autoupdate.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/ohmyzsh-full-autoupdate
    git clone https://github.com/akash329d/zsh-alias-finder "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-alias-finder
    git clone https://github.com/zsh-users/zsh-history-substring-search "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-history-substring-search
    sed -i 's/^plugins=.*/plugins=\( \ngit z github ssh\-agent zsh\-alias\-finder \nohmyzsh\-full\-autoupdate zsh\-syntax\-highlighting \nzsh\-autosuggestions zsh\-history\-substring\-search \n\)/g' "$HOME/.zshrc"
    echo "
--------------------------
--------------------------
Appending '$HOME/.zshrc with' the following content:
--------------------------
    "
    echo "

############################################
############################################

# some customizations following here
neofetch
alias clear='clear;neofetch'
alias _='sudo'
alias su='su - '
alias ll='ls -laAt'
alias llt='ls -laARt'
alias lld='ls -laAdRt'
    " | tee -a "$HOME/.zshrc"
    # shellcheck disable=SC2016
    echo '
# extending PATH environment
    export PATH="$HOME/sbin:$HOME/.local/sbin:$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:$PATH"' | tee -a "$HOME/.zshrc"
    rm -rfv "$HOME/.zshrc.pre-oh-my-zsh"
    cp -afv "$HOME"/.*zsh* /etc/skel/
    mkdir -v "$HOME/.ssh";cd "$HOME/.ssh" || exit 1
    curl https://github.com/datflowts.keys | tee -a authorized_keys
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1rg+YI9Nwj1nAA0qyQROPeawTbZKYNc59igOaFdHr0sCfq1eXnC7GLXYmJhAu1N8g9xdqbUBtSwaNg54qR9NNH7S25Fuu4fRj6nuDky1Gws0GctvL//rTnKB3xS6MJ0FMn4s3Hg9q34LmQGwSDE1m76V115MyMRJIabzo1x1VOEgHZcxEIEI15hij2GpI5vOWYQrjrC4Y70/zQQmRNsbZDvCyrAvSOFLXi/Q74q+gY/7ic3V95ViFQdtt8pCORN3vX73/04kS3I8/EFALF3SO8MWQ8P9w8TT8Is1OjqaO09L7dpwyPtON5FucR7x4NMP/M3XBjWbvKZSkjLg4nzF9Bs7eqyRrqdMxNGcGOcfnqntY70OgHDRJpOloCT/f0RtUSI1ox8L7yRn5fpQt1830XM1tmWApf9jGlhUt9STBJi4m0p1OmMJmDzgkpunC28Q8wtIluaDQhd3fvtfjK0I4uMvbEzwgXEfldem0sAI0H8dIaXIuJ19a/2ILeYnw31s=" | tee -a authorized_keys
    cp -afv "$HOME"/.*ssh* /etc/skel/
    cd /usr/local/bin || exit 1
    update_script=$(find /usr/local/bin -name 'update')
    if [[ -z "$update_script" ]]; then
        echo "No update script found. Installing..."
    else
        echo "Update script already existing. Replacing with new one..."
        rm -fv update
    fi
    echo "
--------------------------
--------------------------
Setting up 'update' command:
--------------------------
    "
    touch update
    # shellcheck disable=SC2016
    echo '#\!/usr/bin/env zsh

UPDATE_LOG=$(sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh)" '\''update'\'')


{
    function get_version_id() {
        local version_id=$(cat /etc/os-release | grep '\''^VERSION_ID='\'' | head -1 | sed '\''s/VERSION_ID=//'\'' | sed '\''s/"//g'\'' | awk '\''{print $1}'\'' | awk '\''BEGIN {FS="."} {print $1}'\'')

        echo $version_id
    }
    distro_version=$(get_version_id)
    export distro_version
    rm -rfv /usr/bin/neofetch
    curl -s https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch -o /usr/bin/neofetch
    chmod -v 555 /usr/bin/neofetch
    # Optionally you can pass an argument for dnf, e.g. "--nobest"
    old_nodejs=$(nvm current)
    nvm install node
    nvm uninstall $old_nodejs
    dnf clean all
    dnf -y upgrade --refresh $@
    dnf clean all
    echo "
    Finished! Your system is up2date now! Reboot recommended.
    You can find details in $UPDATE_LOG.
    "
    read -p "Reebot now? (Y/N, default N) => " -n 1 -r
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        echo "You chosed to reboot after the update.
        Rebooting now..."
        shutdown -r now
    fi
    } | tee -a "$UPDATE_LOG"' | tee -a update
    chmod -v 555 update
    echo "
--------------------------
--------------------------
Yeah, 'update' command is now available!
    "
    cd ~ || exit 1
    sudo sed -i '/^Defaults secure_path/ s/$/:\/usr\/local\/bin/' /etc/sudoers
    echo "
#############################################################
#############################################################
#############################################################
Operating as root could be risky. It's recommended to
create other users with sudo privileges and disable root."
read -p "Do you want to create another user now? (Y/N, default N) => " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/create_user_secure_SSH.sh)"
    fi
    echo "
#############################################################
#############################################################
#############################################################

Now we're checking your connection!

#############################################################
#############################################################
#############################################################
    "
    speedtest --accept-license --accept-gdpr
#    if notCancelled "$USRNAME"; then
#        read -p "Install KDE Plasma Desktop, too? (Y/N, default N) => " -n 1 -r
#        echo ""
#        if [[ $REPLY =~ ^[Yy]$ ]]; then
#            echo "Installing KDE Plasma Desktop...."
#            sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/install_kde_plasma.sh)"
#        fi
#    fi
    update '--best'
    echo '
#############################################################
#############################################################
#############################################################
Finished! Reboot recommended!
    '
    read -p "Reebot now? (Y/N, default N) => " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        shutdown -r now
    fi
} | tee -a "$LOG_FILE" | tee -a "$CONFIG_LOG"
