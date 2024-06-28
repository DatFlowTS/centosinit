#!/bin/env bash

LOGS_PATH="$HOME/scriptlogs"
cd "$LOGS_PATH" || mkdir -vp "$LOGS_PATH/{setup,update,config}" >&2 || exit 1

SETUP_LOGS_PATH="$LOGS_PATH/setup"
CONFIG_LOGS_PATH="$LOGS_PATH/config"
UPDATE_LOGS_PATH="$LOGS_PATH/update"

LOG_FILE=""

case "${1}" in
    "setup")
        cd "$SETUP_LOGS_PATH" || mkdir -vp "$SETUP_LOGS_PATH" >&2 || exit 1
        LOG_FILE="$SETUP_LOGS_PATH/$(date +%F).log"
    ;;
    "config")
        cd "$CONFIG_LOGS_PATH" || mkdir -vp "$CONFIG_LOGS_PATH" >&2 || exit 1
        LOG_FILE="$CONFIG_LOGS_PATH/$(date +%F).log"
    ;;
    "update")
        cd "$UPDATE_LOGS_PATH" || mkdir -vp "$UPDATE_LOGS_PATH" >&2 || exit 1
        LOG_FILE="$UPDATE_LOGS_PATH/$(date +%F).log"
    ;;
    *)
        echo "Invalid argument '$1'!" >&2
        exit 1
    ;;
esac

touch "$LOG_FILE"
echo "
------------------------------------
Created Logfile: $LOG_FILE
------------------------------------
" >&2

echo "$LOG_FILE"
