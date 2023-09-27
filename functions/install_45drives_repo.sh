#!/bin/bash

if [ "$distro" == "rhel" ] || [ "$distro" == "fedora" ]; then
	items=$(find /etc/yum.repos.d -name '45drives.repo')

	if [[ -z "$items" ]]; then
		echo "There were no existing 45Drives repos found. Setting up the new repo..." | tee -a $CONFIG_LOG
	else
		count=$(echo "$items" | wc -l)
		echo "There were $count 45Drives repo(s) found. Archiving..." | tee -a $CONFIG_LOG

		mkdir -vp /opt/45drives/archives/repos | tee -a $CONFIG_LOG

		mv -v /etc/yum.repos.d/45drives.repo /opt/45drives/archives/repos/45drives-$(date +%Y-%m-%d).repo | tee -a $CONFIG_LOG

		echo "The obsolete repos have been archived to '/opt/45drives/archives/repos'. Setting up the new repo..." | tee -a $CONFIG_LOG
	fi

	curl -sSL https://repo.45drives.com/lists/45drives.repo -o /etc/yum.repos.d/45drives.repo | tee -a $CONFIG_LOG

	res=$?

	if [ "$res" -ne "0" ]; then
		echo "Failed to download the new repo file. Please review the above error and try again." | tee -a $CONFIG_LOG
		exit 1
	fi

	el_id="none"

	if [[ "$distro_version" == "7" ]] || [[ "$distro_version" == "8" ]]; then
		el_id=$distro_version
	fi

	if [[ "$custom_distro" != "fedora" ]] && [[ "$distro_version" != "7" ]] && [[ "$distro_version" != "8" ]]; then
		read -p "You are on an unsupported version of Enterprise Linux ('EL${distro_version}'). Would you like to use 'el8' packages? [y/N] " response

		case $response in
			[yY]|[yY][eE][sS])
				echo "Using 'el8' packages due to unsupported distro version 'EL${distro_version}'" | tee -a $CONFIG_LOGtee -a $LOGFILE 
				;;
			*)
				echo "Exiting..." | tee -a $CONFIG_LOG
				exit 1
				;;
		esac

		el_id=8
	fi

	if [[ "$custom_distro" == "fedora" ]]; then
		el_id=8
	fi

	if [[ "$el_id" == "none" ]]; then
		echo "Failed to detect the repo that would best suit your system. Please contact repo@45drives.com to get this issue rectified!" | tee -a $LOGFILE
		exit 1
	fi

	sed -i "s/el8/el$el_id/g;s/EL8/EL$el_id/g" /etc/yum.repos.d/45drives.repo

	res=$?

	if [ "$res" -ne "0" ]; then
		echo "Failed to update the new repo file. Please review the above error and try again." | tee -a $LOGFILE
		exit 1
	fi

	echo "The new repo file has been downloaded. Updating your package lists..." | tee -a $LOGFILE

	pm_bin=dnf

	command -v dnf > /dev/null 2>&1 || {
		pm_bin=yum
	}

	echo "Using the '$pm_bin' package manager..." | tee -a $LOGFILE

	$pm_bin clean all -y | tee -a $LOGFILE

	res=$?

	if [ "$res" -ne "0" ]; then
		echo "Failed to run '$pm_bin clean all -y'. Please review the above error and try again." | tee -a $LOGFILE
		exit 1
	fi

	echo "Success! Your repo has been updated to our new server!" | tee -a $LOGFILE
	exit 0
fi

if [ "$distro" == "debian" ]; then
	items=$(find /etc/apt/sources.list.d -name 45drives.list)

	if [[ -z "$items" ]]; then
		echo "There were no existing 45Drives repos found. Setting up the new repo..." | tee -a $LOGFILE
	else
		count=$(echo "$items" | wc -l)
		echo "There were $count 45Drives repo(s) found. Archiving..." | tee -a $LOGFILE

		mkdir -vp /opt/45drives/archives/repos | tee -a $LOGFILE

		mv -v /etc/apt/sources.list.d/45drives.list /opt/45drives/archives/repos/45drives-$(date +%Y-%m-%d).list | tee -a $LOGFILE
	
		echo "The obsolete repos have been archived to '/opt/45drives/archives/repos'. Setting up the new repo..." | tee -a $LOGFILE
	fi

	if [[ -f "/etc/apt/sources.list.d/45drives.sources" ]]; then
		rm -fv /etc/apt/sources.list.d/45drives.sources | tee -a $LOGFILE
	fi

	echo "Updating ca-certificates to ensure certificate validity..." | tee -a $LOGFILE

	apt update | tee -a $LOGFILE
	apt install ca-certificates -y | tee -a $LOGFILE

	wget -qO - https://repo.45drives.com/key/gpg.asc | gpg --pinentry-mode loopback --batch --yes --dearmor -o /usr/share/keyrings/45drives-archive-keyring.gpg | tee -a $LOGFILE

	res=$?

	if [ "$res" -ne "0" ]; then
		echo "Failed to add the gpg key to the apt keyring. Please review the above error and try again." | tee -a $LOGFILE
		exit 1
	fi

	curl -sSL https://repo.45drives.com/lists/45drives.sources -o /etc/apt/sources.list.d/45drives.sources | tee -a $LOGFILE

	res=$?

	if [ "$res" -ne "0" ]; then
		echo "Failed to download the new repo file. Please review the above error and try again." | tee -a $LOGFILE
		exit 1
	fi

	lsb_release_cs=$(lsb_release -cs)

	if [[ "$lsb_release_cs" == "" ]]; then
		echo "Failed to fetch the distribution codename. This is likely because the command, 'lsb_release' is not available. Please install the proper package and try again. (apt install -y lsb-core)" | tee -a $LOGFILE
		exit 1
	fi

	if [[ "$lsb_release_cs" != "focal" ]] && [[ "$lsb_release_cs" != "bionic" ]]; then
	read -p "You are on an unsupported version of Debian. Would you like to use 'focal' packages? [y/N] " response

		case $response in
			[yY]|[yY][eE][sS])
				echo | tee -a $LOGFILE 
				;;
			*)
				echo "Exiting..." | tee -a $LOGFILE
				exit 1
				;;
		esac

		lsb_release_cs="focal"
	fi

	sed -i "s/focal/$lsb_release_cs/g" /etc/apt/sources.list.d/45drives.sources

	res=$?

	if [ "$res" -ne "0" ]; then
		echo "Failed to update the new repo file. Please review the above error and try again." | tee -a $LOGFILE
		exit 1
	fi

	echo "The new repo file has been downloaded. Updating your package lists..." | tee -a $LOGFILE

	pm_bin=apt

	$pm_bin update -y | tee -a $LOGFILE

	res=$?

	if [ "$res" -ne "0" ]; then
		echo "Failed to run '$pm_bin update -y'. Please review the above error and try again." | tee -a $LOGFILE
		exit 1
	fi

	echo "Success! Your repo has been updated to our new server!" | tee -a $LOGFILE
	exit 0
fi

echo -e "\nThis command has been run on a distribution that is not supported by the 45Drives Team.\n\nIf you believe this is a mistake, please contact our team at repo@45drives.com!\n" | tee -a $LOGFILE
exit 1