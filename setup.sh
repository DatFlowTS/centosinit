#!/usr/bin/env bash

euid=$(id -u)

if [ "$euid" -ne 0 ]; then
	echo -e '\nYou must be root to run this utility.\n'
    exit 1
fi


LOGFILE=$(sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh)" 'setup')
distro=$(sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/get_distro_infos.sh)" 'base')
custom_distro=$(sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/get_distro_infos.sh)" 'custom')
distro_version=$(sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/get_distro_infos.sh)" 'version')


if [ "$distro" == "rhel" ] || [ "$distro" == "fedora" ]; then

        echo "Detected RPM distribution. Continuing..." | tee -a "$LOGFILE"
        
        init_script_url="none"
        case "${custom_distro}" in
            [fedora])
                init_script_url="https://raw.github.com/datflowts/linuxinit/master/distro/fedora.sh"
            ;;
            *)
                init_script_url="https://raw.github.com/datflowts/linuxinit/master/distro/el${distro_version}.sh"
            ;;
        esac

        sh -c "$(curl -fsSL "${init_script_url}")"
        

fi

if [ "$distro" == "debian" ]; then

	echo "Detected Debian-based distribution, which is currently not supported yet." | tee -a "$LOGFILE"
        exit 1

#	lsb_release_cs=$(lsb_release -cs)
#
#	if [[ "$lsb_release_cs" == "" ]]; then
#		echo "Failed to fetch the distribution codename. This is likely because the command, 'lsb_release' is not available. Please install the proper package and try again. (apt install -y lsb-core)" | tee -a $LOGFILE
#		exit 1
#	fi

fi