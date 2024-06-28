#!/bin/env bash

LOG_FILE=$(sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh) setup")
CONFIG_LOG=$(sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh) config")

{
    
    if [[ ! -f ~/.bashrc ]]; then
        echo "No bashrc found, creating...."
        
        touch ~/.bashrc
    ~/.bashrc << 'EOF'
# Colors
RED='\[\033[0;31m\]'
GREEN='\[\033[0;32m\]'
YELLOW='\[\033[1;33m\]'
NC='\[\033[0m\]' # No Color

# Display working directory or git infos, depending on current location
if $(git rev-parse --is-inside-work-tree); then
        CURRENT_DIR="${YELLOW}($(basename `git rev-parse --show-toplevel`)$(git rev-parse --abbrev-ref HEAD 2>/dev/null | awk '{print "/"$1}'))${NC}"
else
        CURRENT_DIR="\w"
fi

# Sets prompt finish depending on previous command result
PROMPT_FINISH='$(if [ $? -ne 0 ]; then echo "${RED}!! [ X ] =>${NC}"; else echo "=>"; fi)'

# Add all SSH keys found in ~/.ssh to the ssh agent
for key in ~/.ssh/id_*; do
    [[ -f $key ]] && ssh-add "$key"
done

# Check if the current user is root
if [ $(id -u) -eq 0 ]; then
        USERCOLOR="${RED}\u${NC}@${RED}\h${NC}"
else
        USERCOLOR="${GREEN}\u${NC}@${GREEN}\h${NC}"
fi

# Update PS1 to include date, user, host, working directory or git branch info and exit status
PS1="${RED}[${NC}\D{%a, %d %b %Y - %H:%M}${RED}]${NC} ${USERCOLOR}${RED}:${NC}${CURRENT_DIR}\n${PROMPT_FINISH} "

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

# extending PATH environment
export PATH="$HOME/sbin:$HOME/.local/sbin:$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:$PATH"

EOF
        
    fi
    
} | tee -a "$LOG_FILE" | tee -a "$CONFIG_LOG"