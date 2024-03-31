#!/bin/env bash

{
    shutdown -r now
        echo "
Please, provide a username ('default' to create
a user with username 'default0' or 'cancel' to not create any.):
    "
    read USRNAME
    echo "
--------------------------
checking '$USRNAME' ...
--------------------------
    "
    LOCK=0
    while [[ "$LOCK" -eq "0" ]]; do
        if [[ "$USRNAME" =~ ^([0-9]{0,31}[[:lower:]]{1,32}[0-9]{0,31}){1,32}$ ]]; then
            case "${USRNAME}" in
                default)
                    USRNAME='default0'
                    username_out="You've chosen '$USRNAME'. I'll create a default user named 'default0'
                    Use this as a template user only!"
                ;;
                cancel)
                    USRNAME='CANCELLED'
                    username_out="You cancelled user creation. Please, create a user manually after setup is completed!
                    Otherwise, you'll get locked out from logging in via SSH!"
                ;;
                *)
                    username_out="You've chosen a valid username. In the next step we create a user named '${USRNAME}'"
                ;;
            esac
            echo "$username_out"
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
            "
            LOCK=0
        fi
    done
    notCancelled () {
        local _u=$1
        [[ $_u != 'CANCELLED' ]]
    }
    if notCancelled "$USRNAME"; then
        export NEWUSER=$USRNAME
        useradd -G wheel "$NEWUSER"
        echo "
--------------------------
User '$NEWUSER' successfully created!
--------------------------
--------------------------
        "
    fi
    echo "Disabling root login via SSH and securing global authentication"
    mv -v /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
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
    " | tee -a /etc/ssh/sshd_config
    policy_string="template for upcoming users..."
    policy_usermatch="<USERTEMPLATE>"
    policy_order="99"
    if notCancelled "$USRNAME"; then
        policy_string="for $NEWUSER..."
        policy_usermatch="$NEWUSER"
        policy_order="01"
    fi
    policy_filename="${policy_order}-${policy_usermatch}.conf"
    echo "
--------------------------
Creating SSH security policies $policy_string
--------------------------
    "
    sshd_conf_file="/etc/ssh/sshd_config.d/${policy_filename}"
    touch "$sshd_conf_file"
    echo "
Match User $policy_usermatch
    ChallengeResponseAuthentication yes
    AuthenticationMethods publickey,password publickey,keyboard-interactive
    " | tee -a "$sshd_conf_file"
    echo '
#MFA
auth       required     pam_google_authenticator.so secret=${HOME}/.ssh/google_authenticator nullok
auth       required     pam_permit.so
    ' | tee -a /etc/pam.d/sshd | tee -a /etc/pam.d/cockpit
    gauth_command=/usr/local/bin/gauth_enable_totp
    if [[ ! -f "$gauth_command" ]]; then touch $gauth_command; fi
    chmod -v 555 /usr/local/bin/**
    echo '
#!/usr/bin/env bash
# this is to simplify the creation of google authenticator TOTP
# it creates the related file into ~/.ssh folder and makes sure
# that SELinux is not preventing sshd from accessing it
#
google-authenticator -t -d -f -r 3 -R 30 -w 3 -s "${HOME}/.ssh/google_authenticator"
restorecon -Rv "${HOME}/.ssh/"
    ' > "$gauth_command"
    echo "
#############################################################
#############################################################
#############################################################

Security improved!
-   run 'gauth_totp' as any non-root user to enable TOTP
    Authentication for them
-   run 'passwd <username>' to create a password for
    them (REQUIRED! Yo'll get locked out, if you don't!)
-   for any new user you create, copy $sshd_conf_file with
    the user's name and an incremented number prexfix, from
    01 to 99 and replace '$policy_usermatch' inside the file
    with the new user's username.

#############################################################
#############################################################
#############################################################
    "
    if notCancelled "$USRNAME"; then
        echo "
Setting up pm2 daemon for $NEWUSER and for root.....
        "
        env "PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2" startup systemd -u "$NEWUSER" --hp "/home/$NEWUSER"
        ausearch -c 'systemd' --raw | audit2allow -M "pm2-$NEWUSER"
        semodule -i "pm2-$NEWUSER.pp"
    else
        echo "Setting up pm2 daemon for root..."
    fi
    pm2 startup
    ausearch -c 'systemd' --raw | audit2allow -M "pm2-root"
    semodule -i "pm2-root.pp"
    ausearch -c 'systemd' --raw | audit2allow -M "my-systemd"
    semodule -i "my-systemd.pp"
}