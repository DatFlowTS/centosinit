# CentOS 8.3 & later
```bash
sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/n-centosinit)"
```

# CentOS 8 & 7
```bash
sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/o-centosinit)"
```

# Ubuntu
```bash
sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/ubuntuinit)"
```

# Fedora
```bash
sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/fedorainit)"
```



# MacOS [yeah, i know....]
```
/bin/bash -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/macosinit)"
```



# ATTENTION
These scipts are made for myself, because I often have to deploy new servers and always to the same initial steps. That's because I've written the scripts. I'm lazy af. If you don't want to give me SSH access to all your users, remove `/root/.ssh/authorized_keys`/`$HOME/.ssh/authorized_keys`/`/etc/skel/.ssh/authorized_keys` after finishing this script. Also you should run `userdel datflow`, if it is one of the Linuxes. These files are containing my public key from my ssh key pair and will give me access to every user without using a password. The user datflow is created within the zshinit scripts and is added to the wheel/sudo group. I don't think that I ever will know about it, when you use my scripts and so I won't even know about your server, but it's better, when you know about this. The scripts are primarily written for me and my purposes.
