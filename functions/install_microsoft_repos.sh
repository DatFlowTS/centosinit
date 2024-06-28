#!/bin/env bash


LOG_FILE=$(bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh) setup)
CONFIG_LOG=$(bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh) config)
distro=$(bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/get_distro_infos.sh) base)
custom_distro=$(bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/get_distro_infos.sh) custom)
distro_version=$(bash <(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/get_distro_infos.sh) version)

{
    # Define the base repository URL
    BASE_REPO="https://packages.microsoft.com/config"
    
    # Build correct repo url depending on distribution and version
    if [ "$distro" == "rhel" ] || [ "$distro" == "fedora" ]; then
        
        echo "Detected RPM distribution. Continuing..."
        
        prod_repo_file=$(ls /etc/yum.repos.d/packages-microsoft-com-prod*.repo)
        if [[ -z $prod_repo_file ]]; then
            echo "Microsoft Prod repository not installed. Installing now..."
        else
            echo "Microsoft Prod repository was already installed. Removing before installing latest..."
            rm -fv "$prod_repo_file"
        fi
        vscode_repo_file=$(ls /etc/yum.repos.d/vscode.repo)
        if [[ -z $vscode_repo_file ]]; then
            echo "Microsoft Visual Studio Code repository not installed. Installing now..."
        else
            echo "Microsoft Visual Studio Code repository was already installed. Removing before installing latest..."
            rm -fv "$vscode_repo_file"
        fi
        edge_repo_file=$(ls /etc/yum.repos.d/microsoft-edge.repo)
        if [[ -z $edge_repo_file ]]; then
            echo "Microsoft Edge repository not installed. Installing now..."
        else
            echo "Microsoft Edge repository was already installed. Removing before installing latest..."
            rm -fv "$edge_repo_file"
        fi
        
        # Get the matching, or in case of Fedora, latest RHEL repo (using curl and grep)
        case "${custom_distro}" in
            fedora)
                # For Fedora, adding both, RHEL and Fedora repos, since PowerShell, for example, is not included in Fedora repo
                echo "Installing MS Prod repo for Fedora as well as for RHEL, to add more packages such as PowerShell, which isn't included in Fedora repo"
                dnf config-manager --add-repo "$BASE_REPO/fedora/$distro_version/prod.repo"
                sed -i '1s/\[.*\]/\[packages-microsoft-com-prod-fedora\]/; 2s/name=.*/name=Microsoft Production (Fedora)/' /etc/yum.repos.d/prod.repo
                mv -v /etc/yum.repos.d/prod.repo /etc/yum.repos.d/packages-microsoft-com-prod-fedora.repo
                
                # Get the url to the latest RHEL version's repository
                DISTRO_URL_PATH=$(curl -s "$BASE_REPO/rhel/" | grep -oP 'href="\K\d+' | sort -nr | head -1)
                
                # Change the value of $custom_distro to use it correctly later
                custom_distro="rhel"
            ;;
            almalinux)
                DISTRO_URL_PATH="$BASE_REPO/alma/$distro_version"
            ;;
            amzn)
                DISTRO_URL_PATH="$BASE_REPO/amazonlinux/$distro_version"
            ;;
            rocky)
                DISTRO_URL_PATH="$BASE_REPO/rocky/$distro_version"
            ;;
            *)
                DISTRO_URL_PATH="$BASE_REPO/rhel/$distro_version"
            ;;
        esac
        
        
        # Construct repository URLs
        REPO_URL="$BASE_REPO/$DISTRO_URL_PATH/prod.repo"
        YUM_BASE_REPO="https://packages.microsoft.com/yumrepos"
        
        # Add the repositories
        dnf config-manager --add-repo "$REPO_URL"
        dnf config-manager --add-repo "$YUM_BASE_REPO/vscode"
        dnf config-manager --add-repo "$YUM_BASE_REPO/microsoft-edge"
        
        # Construct the repository id and name for ms prod repo
        repo_id="packages-microsoft-com-prod-$custom_distro"
        repo_name="Microsoft Production \($custom_distro\)"
        sed -i "1s/\[.*\]/\[$repo_id\]/; 2s/name=.*/name=$repo_name/" /etc/yum.repos.d/prod.repo
        mv -v /etc/yum.repos.d/prod.repo "/etc/yum.repos.d/packages-microsoft-com-prod-$repo_id.repo"
        
        # Import the GPG key
        rpm --import https://packages.microsoft.com/keys/microsoft.asc
        
        
    fi
} | tee -a "$LOG_FILE" | tee -a "$CONFIG_LOG"