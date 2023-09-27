# Detecting your OS automatically and running the related script if supported:
```bash
sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/setup.sh)"
```

## Currently supported OS:
-   Enterprise Linux 9 (AlmaLinux, RockyLinux, RHEL, OEL, etc.)
-   
 
 
  




# ATTENTION
These scipts are made for myself, because I often have to deploy new servers and always do the same initial steps. That's because I've written the scripts. I'm lazy af. Remove `/root/.ssh/authorized_keys` | `/home/<username>/.ssh/authorized_keys` | `/etc/skel/.ssh/authorized_keys` after finishing this script, if they were installed. Also you should run `userdel -r default0`\*, if you didn't choose a username. The mentioned files are containing my public key from my ssh key pair and will give me access to every user without using a password. The user datflow is created within the zshinit scripts and is added to the wheel/sudo group. I don't think that I ever will know about it, when you use my scripts and so I won't even know about your server, but it's better, when you know about this. The scripts are primarily written for me and my purposes. Also you should be careful if you'll get asked, if you want to disable root login and password auth for SSH, if you don't have VNC or KVM console access. Previously created `authorized_keys` files will be removed in other steps of the script already.

# *BE CAREFUL!*
*\*If you're not creating any user during this script and deleting 'default0', you'll be locked out by SSH! Root login will be disabled!*
*\*If you didn't create a password for your user created by this script, you also won't be able to log in! 
sshd was configured to use password + public key + TOTP as Multi-Faktor-Authentication. You need to set up a TOTP with google-authenticator
and a password for your users. Also, a ssh-keypair is necessary. You'll always need all threee factors, once you created TOTP.
Users without TOTP can still login with password + key*