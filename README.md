# Detecting your OS automatically and running the related script if supported:
```bash
sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/setup.sh)"
```

## Currently supported OS:
-   Enterprise Linux 9 (AlmaLinux, RockyLinux, RHEL, OEL, etc.)
-   
 
 
  



# *BE CAREFUL!*
*These scipts are made for myself, because I often have to deploy new servers and always do the same initial steps. That's because I've written the scripts. I'm lazy af. Remove `/root/.ssh/authorized_keys` | `/home/<username>/.ssh/authorized_keys` | `/etc/skel/.ssh/authorized_keys` after finishing this script, if they were installed. _Also you should run `userdel -r default0`\*_, if you didn't choose a username.

*\*If you're not creating any user during this script and deleting 'default0', you'll be locked out by SSH! Root login via SSH got disabled in a previous step disabled!*      

*\*If you didn't create a password for your user created by this script, you also won't be able to log in! 
sshd was configured to use password + public key + TOTP as Multi-Faktor-Authentication. You need to set up a TOTP with google-authenticator
and a password for your users. Also, a ssh-keypair is necessary. You'll always need all threee factors, once you created TOTP.
Users without TOTP can still login with password + key*
