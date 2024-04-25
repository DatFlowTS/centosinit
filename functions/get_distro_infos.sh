#!/bin/env bash

LOGFILE=$(sh -c "$(curl -fsSL https://raw.github.com/datflowts/linuxinit/master/functions/provide_logfile.sh)" 'setup')

function get_base_distro() {
    local distro
    # shellcheck disable=SC2002
    distro=$(cat /etc/os-release | grep '^ID_LIKE=' | head -1 | sed 's/ID_LIKE=//' | sed 's/"//g' | awk '{print $1}')
    
    if [ -z "$distro" ]; then
        # shellcheck disable=SC2002
        distro=$(cat /etc/os-release | grep '^ID=' | head -1 | sed 's/ID=//' | sed 's/"//g' | awk '{print $1}')
    fi
    
    echo "Base distribution:" >&2
    echo "$distro"
}

function get_custom_distro() {
    local distro
    # shellcheck disable=SC2002
    distro=$(cat /etc/os-release | grep '^ID=' | head -1 | sed 's/ID=//' | sed 's/"//g' | awk '{print $1}')
    
    echo "Custom distribution:" >&2
    echo "$distro"
}

function get_version_id() {
    local version_id
    # shellcheck disable=SC2002
    version_id=$(cat /etc/os-release | grep '^VERSION_ID=' | head -1 | sed 's/VERSION_ID=//' | sed 's/"//g' | awk '{print $1}' | awk 'BEGIN {FS="."} {print $1}')
    
    echo "Distribution's current version:" >&2
    echo "$version_id"
}
{
    echo "
Checking Distribution infos.....
    " >&2
    
    case "${1}" in
        [base])
            get_base_distro
        ;;
        [custom])
            get_custom_distro
        ;;
        [version])
            get_version_id
        ;;
        *)
            echo "Invalid argument '${1}'!" >&2
            exit 1
        ;;
    esac
} | tee -a "$LOGFILE"