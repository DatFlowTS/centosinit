# Rocky Linux 8
```bash
sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/rockyinit)"
```

# CentOS 8.3++*
```bash
sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/centosinit)"
```

# Ubuntu 20.04
```bash
sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/ubuntuinit)"
```

# Fedora 30*
```bash
sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/fedorainit)"
```
 
 
  
# MacOS [yeah, i know....] 10*
```
/bin/bash -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/macosinit)"
```



# ATTENTION
These scipts are made for myself, because I often have to deploy new servers and always do the same initial steps. That's because I've written the scripts. I'm lazy af. Remove `/root/.ssh/authorized_keys` | `$HOME/.ssh/authorized_keys` | `/etc/skel/.ssh/authorized_keys` after finishing this script, if they were installed. Also you should run `userdel -r datflow`, if it was created and it is one of the Linuxes. The mentioned files are containing my public key from my ssh key pair and will give me access to every user without using a password. The user datflow is created within the zshinit scripts and is added to the wheel/sudo group. I don't think that I ever will know about it, when you use my scripts and so I won't even know about your server, but it's better, when you know about this. The scripts are primarily written for me and my purposes.

*\*Scripts marked weren't updated for a long time or won't be updated anymore in the future. Due to the EOL, CentOS will definitely not be supported nor used by me anymore. Instead I'll focus on Rocky Linux, Fedora, some Ubuntu and maybe in the future, AlmaLinux. MacOS will get an update, when I have to use it myself again.*
