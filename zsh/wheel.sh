#!/bin/zsh

echo "Preparing to set up OhMyZSH...
--------------------------
" | tee -a $LOGFILE
rm -rfv $HOME/.*ssh* $HOME/.*zsh* /etc/skel/.*ssh* /etc/skel/.*zsh* | tee -a $LOGFILE
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | tee -a $LOGFILE
sed -i 's/RUNZSH=\${RUNZSH:-yes}/RUNZSH=\${RUNZSH:-no}/g' install.sh
sed -i 's/RUNZSH=yes/RUNZSH=no/g' install.sh
sed -i 's/CHSH=\${CHSH:-yes}/CHSH=\${CHSH:-no}/g' install.sh
sed -i 's/CHSH=yes/CHSH=no/g' install.sh
echo "
--------------------------
Running OhMyZSH installer:
--------------------------
--------------------------
" | tee -a $LOGFILE
sh install.sh | tee -a $LOGFILE
rm -fv install.sh | tee -a $LOGFILE
sed -i 's/robbyrussell/powerlevel10k\/powerlevel10k/g' $HOME/.zshrc
sed -i 's/\/root/\$HOME/g' $HOME/.zshrc
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/Pilaton/OhMyZsh-full-autoupdate.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ohmyzsh-full-autoupdate
git clone https://github.com/akash329d/zsh-alias-finder ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-alias-finder
sed -i 's/^plugins=.*/plugins=\( \ngit z github ssh\-agent zsh\-alias\-finder \nohmyzsh\-full\-autoupdate zsh\-syntax\-highlighting \nzsh\-autosuggestions zsh\-history\-substring\-search \n\)/g' $HOME/.zshrc
echo "
--------------------------
--------------------------
Appending $HOME/.zshrc with the following content:
--------------------------
"  | tee -a $LOGFILE
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
" | tee -a $HOME/.zshrc | tee -a $LOGFILE
echo '
# extending PATH environment
export PATH="$HOME/sbin:$HOME/.local/sbin:$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:$PATH"' | tee -a $HOME/.zshrc | tee -a $LOGFILE
rm -rfv $HOME/.zshrc.pre-oh-my-zsh | tee -a $LOGFILE
cp -afv $HOME/.*zsh* /etc/skel/ | tee -a $LOGFILE
mkdir -v $HOME/.ssh | tee -a $LOGFILE;cd $HOME/.ssh
curl https://github.com/datflowts.keys | tee -a authorized_keys | tee -a $LOGFILE
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1rg+YI9Nwj1nAA0qyQROPeawTbZKYNc59igOaFdHr0sCfq1eXnC7GLXYmJhAu1N8g9xdqbUBtSwaNg54qR9NNH7S25Fuu4fRj6nuDky1Gws0GctvL//rTnKB3xS6MJ0FMn4s3Hg9q34LmQGwSDE1m76V115MyMRJIabzo1x1VOEgHZcxEIEI15hij2GpI5vOWYQrjrC4Y70/zQQmRNsbZDvCyrAvSOFLXi/Q74q+gY/7ic3V95ViFQdtt8pCORN3vX73/04kS3I8/EFALF3SO8MWQ8P9w8TT8Is1OjqaO09L7dpwyPtON5FucR7x4NMP/M3XBjWbvKZSkjLg4nzF9Bs7eqyRrqdMxNGcGOcfnqntY70OgHDRJpOloCT/f0RtUSI1ox8L7yRn5fpQt1830XM1tmWApf9jGlhUt9STBJi4m0p1OmMJmDzgkpunC28Q8wtIluaDQhd3fvtfjK0I4uMvbEzwgXEfldem0sAI0H8dIaXIuJ19a/2ILeYnw31s=" | tee -a authorized_keys | tee -a $LOGFILE
cp -afv $HOME/.*ssh* /etc/skel/ | tee -a $LOGFILE
cd /usr/local/bin
echo "
--------------------------
--------------------------
Setting up 'update' command:
--------------------------
" | tee -a $LOGFILE
touch update
echo '#\!/bin/zsh

mkdir -p $HOME/scriptlogs/{init,update,config}
UPDATE_LOG=$HOME/scriptslogs/update/$(date +%F).log

# Optionally you can pass an argument for dnf, e.g. "--nobest"
rm -rfv /usr/bin/neofetch | tee -a $UPDATE_LOG
curl -s https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch -o /usr/bin/neofetch | tee -a $UPDATE_LOG
chmod -v 555 /usr/bin/neofetch | tee -a $UPDATE_LOG 
dnf -y upgrade --refresh $@ | tee -a $UPDATE_LOG
dnf clean all | tee -a $UPDATE_LOG
echo "
Finished! Your system is up2date now! Reboot recommended.
You can find details in $UPDATE_LOG.
" | tee -a $UPDATE_LOG
read -p "Reebot now? (Y/N, default N) => " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "You chosed to reboot after the update. 
    Rebooting now..." | tee -a $LOGFILE
    shutdown -r now | tee -a $UPDATE_LOG
fi
' | tee -a update | tee -a $LOGFILE
echo "
--------------------------
--------------------------
Yeah, 'update' command is now available!
" | tee -a $LOGFILE
cd ~
echo "
--------------------------
--------------------------
Installing powerline fonts
--------------------------
" | tee -a $LOGFILE
git clone https://github.com/powerline/fonts.git --depth=1 | tee -a $LOGFILE
cd fonts
./install.sh | tee -a $LOGFILE
cd ..
rm -rf fonts
cp -afv $HOME/.local /etc/skel/ | tee -a $LOGFILE
chmod -v 555 /usr/local/bin/** | tee -a $LOGFILE
touch .hushlogin
touch /etc/skel/.hushlogin
echo "
#############################################################
#############################################################
#############################################################
Operating as root could be risky. It's recommended to
create other users with sudo privileges and disable root.
So, let's define your default user! 
Please, provide a username ('default' or 'cancel' to create
a user with username 'default0'):
"
read USRNAME
echo "
--------------------------
checking '$USRNAME' ...
--------------------------
" | tee -a $LOGFILE
LOCK=0
while [[ "$LOCK" -eq "0" ]]; do
esac
    if [[ "$USRNAME" =~ ^([0-9]{0,31}[[:lower:]]{1,32}[0-9]{0,31}){1,32}$ ]]; then
        case "${USRNAME}}" in
            [default])
                USRNAME='default0'
                username_out="You've chosen '$USRNAME'. I'll create a default user named 'default0'
                Use this as a template user only!"
            ;;
            [cancel]
                USRNAME='CANCELLED'
                username_out="You cancelled user creation. Please, create a user manually after setup is completed!
                Otherwise, you'll get locked out from logging in via SSH!"
            ;;
            *)
                username_out="You've chosen a valid username. In the next step we create a user named '${USRNAME}'"
            ;;
        esac
        
        if [[ "$USRNAME" == "default" ]] | [[ "$USRNAME" == "cancel" ]]; then
        fi
        echo $username_out | tee -a $LOGFILE
        LOCK=1
    else
        echo "Please provide a valid unix username:
- only 1-32 lowercase alphanumeric characters allowed
- at least one alphabetic letter is required
Try again or type 'cancel' or 'default' to cancel and proceed with setup
Then a user named 'default0' will be created"
        read USRNAME
        echo "
--------------------------
checking '${USRNAME}' ...
--------------------------
" | tee -a $LOGFILE
        LOCK=0
    fi
done
export NEWUSER=$USRNAME
useradd -G wheel $NEWUSER
echo "
--------------------------
User '$NEWUSER' successfully created!
--------------------------
--------------------------
" | tee -a $LOGFILE
echo "Disabling root login via SSH and securing global authentication" | tee -a $LOGFILE | tee -a $CONFIG_LOG
mv -v /etc/ssh/sshd_config /etc/ssh/sshd_config.bak | tee -a $CONFIG_LOG
touch /etc/ssh/sshd_config
echo "
Include /etc/ssh/sshd_config.d/*.conf
PermitRootLogin no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication yes
PermitEmptyPasswords no
KbdInteractiveAuthentication yes
PermitEmptyPasswords no
UsePAM yes
Subsystem sftp  /usr/libexec/openssh/sftp-server
" | tee -a /etc/ssh/sshd_config | tee -a $CONFIG_LOG
echo "
--------------------------
Creating SSH security policies for $NEWUSER...
--------------------------
" | tee -a $LOGFILE | tee -a $CONFIG_LOG
sshd_conf_file=/etc/ssh/sshd_config.d/$NEWUSER.conf
touch $sshd_conf_file
echo "
Match User $NEWUSER
    ChallengeResponseAuthentication yes
    AuthenticationMethods publickey,password publickey,keyboard-interactive
" | tee -a $sshd_conf_file | tee -a $LOGFILE | tee -a $CONFIG_LOG
sed -i '3i auth       required     pam_google_authenticator.so nullock' /etc/pam.d/{cockpit,sshd}
sed -i '4i auth       required     pam_permit.so' /etc/pam.d/{cockpit,sshd}
echo "
#############################################################
#############################################################
#############################################################

Security improved!
-   run 'google-authenticator -t -d -f -r 3 -R 30 -w 3' as 
    $NEWUSER to create TOTP Authentication.
-   run 'passwd $NEWUSER' to create a password for
    $NEWUSER (REQUIRED! Yo'll get locked out, if you don't!)
-   for any new user you create, copy $sshd_conf_file with
    the user's name and replace $NEWUSER inside the file 
    with the new user's name.

#############################################################
#############################################################
#############################################################

Setting up pm2 daemon for $NEWUSER and for root.....
" | tee -a $LOGFILE | tee -a $CONFIG_LOG
env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u $NEWUSER --hp /home/$NEWUSER | tee -a $LOGFILE | tee -a $CONFIG_LOG
pm2 startup | tee -a $LOGFILE | tee -a $CONFIG_LOG
echo "
#############################################################
#############################################################
#############################################################

Now we're checking your connection!

#############################################################
#############################################################
#############################################################
" | tee -a $LOGFILE
speedtest --accept-license | tee -a $LOGFILE
read -p "Install KDE Plasma Desktop, too? (Y/N, default N) => " -n 1 -r
echo "" | tee -a $LOGFILE
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing KDE Plasma Desktop...." | tee -a $LOGFILE
    sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/kde_plasma_desktop.sh)"
fi
update '--best' | tee -a $LOGFILE
echo '
#############################################################
#############################################################
#############################################################
Finished! Reboot recommended!
' | tee -a $LOGFILE
read -p "Reebot now? (Y/N, default N) => " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    shutdown -r now | tee -a $LOGFILE
fi