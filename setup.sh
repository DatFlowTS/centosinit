#!/bin/bash

euid=$(id -u)

if [ $euid -ne 0 ]; then
	echo -e '\nYou must be root to run this utility.\n'
    exit 1
fi

mkdir -vp $HOME/scriptlogs/{init,update,config}
LOGFILE="$HOME/scriptlogs/init/$(date +%F).log"
CONFIG_LOG="$HOME/scriptlogs/config/$(date +%F).log"
UPDATE_LOG="$HOME/scriptlogs/update/$(date +%F).log"
export LOGFILE
export CONFIG_LOG
export UPDATE_LOG

touch $LOGFILE
touch $CONFIG_LOG
touch $UPDATE_LOG
echo "
------------------------------------
Created Logfiles:
-       $LOGFILE
-       $CONFIG_LOG
-       $UPDATE_LOG
------------------------------------

Checking Distribution & Version.....
" | tee -a $LOGFILE

function get_base_distro() {
        local distro=$(cat /etc/os-release | grep '^ID_LIKE=' | head -1 | sed 's/ID_LIKE=//' | sed 's/"//g' | awk '{print $1}')

        if [ -z "$distro" ]; then
                distro=$(cat /etc/os-release | grep '^ID=' | head -1 | sed 's/ID=//' | sed 's/"//g' | awk '{print $1}')
        fi

        echo $distro | tee -a $LOGFILE
}

function get_distro() {
        local distro=$(cat /etc/os-release | grep '^ID=' | head -1 | sed 's/ID=//' | sed 's/"//g' | awk '{print $1}')

        echo $distro | tee -a $LOGFILE
}

function get_version_id() {
        local version_id=$(cat /etc/os-release | grep '^VERSION_ID=' | head -1 | sed 's/VERSION_ID=//' | sed 's/"//g' | awk '{print $1}' | awk 'BEGIN {FS="."} {print $1}')

        echo $version_id | tee -a $LOGFILE
}

distro=$(get_base_distro)
custom_distro=$(get_distro)
distro_version=$(get_version_id)

export distro
export custom_distro
export distro_version

if [ "$distro" == "rhel" ] || [ "$distro" == "fedora" ]; then

        echo "Detected RHEL-based distribution. Continuing..." | tee -a $LOGFILE
        
        init_script_url="none"
        case "${custom_distro}" in
            [fedora])
                init_script_url="https://raw.github.com/datflowts/linuxinit/master/distro/fedora.sh"
            ;;
            *)
                init_script_url="https://raw.github.com/datflowts/linuxinit/master/distro/el${distro_version}.sh"
            ;;
        esac

        sh -c "$(curl -fsSL ${init_script_url})"
        

fi

if [ "$distro" == "debian" ]; then

	echo "Detected Debian-based distribution. Continuing..." | tee -a $LOGFILE

	lsb_release_cs=$(lsb_release -cs)

	if [[ "$lsb_release_cs" == "" ]]; then
		echo "Failed to fetch the distribution codename. This is likely because the command, 'lsb_release' is not available. Please install the proper package and try again. (apt install -y lsb-core)" | tee -a $LOGFILE
		exit 1
	fi

fi