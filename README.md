# CentOS
```bash
sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/centosinit)"
```

# Ubuntu
```bash
sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/ubuntuinit)"
```

# Fedora
```bash
sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/fedorainit)"
```



# ATTENTION
If you don't want to give me SSH access to all your users, remove `/root/.ssh/authorized_keys` and `/etc/skel/.ssh/authorized_keys` after finishing this script.
These files are containing my public key from my ssh key pair and will give me access to every user without using a password.
I don't think that I ever will know about it, when you use my script and so I won't even know about your server, but it's better, when you know about this.
This script is primarily written for me and my purposes.
