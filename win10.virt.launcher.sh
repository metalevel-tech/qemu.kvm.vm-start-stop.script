#!/bin/bash

if [[ $1 == "backup" ]]
then
    echo "Backup..."
    DUMP_DIR="$(readlink -f "$0")"
    DUMP_DIR="${DUMP_DIR%/*}/vm-dumpxml"
    echo "Dump directory: ${DUMP_DIR}"

    virsh --connect qemu:///system dumpxml "Win10" >"${DUMP_DIR}/Win10_$(date +%y%m%d).xml" 2>/dev/null
    virsh --connect qemu:///system dumpxml "Win10PT" >"${DUMP_DIR}/Win10PT_$(date +%y%m%d).xml" 2>/dev/null
    exit
fi

if [[ $1 == "deploy" ]]
then
    echo "Deploying..."

    # https://stackoverflow.com/a/5750463/6543935
    set -o xtrace

    # Create .dsktop files
    cp "./desktop-files/launch.win10"*".desktop" "${HOME}/Desktop/"
    cp "./desktop-files/launch.win10"*".desktop" "${HOME}/.local/share/applications/"
    update-desktop-database "${HOME}/.local/share/applications/"

    # Copy the icons
    mkdir -p "${HOME}/.local/share/icons"
    cp "./icons/"*".png" "${HOME}/.local/share/icons/"
    update-icon-caches ~/.local/share/icons/*
    
    # link the script itself as cli command 
    mkdir -p "${HOME}/.local/bin"
    rm -f "${HOME}/.local/bin/${0##*/}"
    ln -s "${PWD}/${0##*/}" "${HOME}/.local/bin/"
    exit
fi

virsh --connect qemu:///system list | grep -q 'Win10'
IS_WIN10_RUNNING=$?

if [[ $IS_WIN10_RUNNING -eq 0 ]]
then
    echo "Status: ${IS_WIN10_RUNNING} running"
else
    echo "Status: ${IS_WIN10_RUNNING} stopped"
fi

if [[ $1 == "stop" ]]
then
    echo "Stopping..."

    if [[ $IS_WIN10_RUNNING == 0 ]]
    then
        virsh --connect qemu:///system shutdown "Win10" 2>/dev/null
        virsh --connect qemu:///system shutdown "Win10PT" 2>/dev/null
    else
	echo "Nothing to stop."
    fi
else
    echo "Starting..."

    if [[ $1 == "start" ]]
    then
        virsh --connect qemu:///system list | grep -q -w 'Win10PT'
        IS_WIN10_RUNNING=$?
        if [[ $IS_WIN10_RUNNING == 0 ]]
        then
            echo "First use: ${0##*/} stop"
            exit
        else
            virsh --connect qemu:///system start "Win10" 2>/dev/null
            virt-viewer --connect qemu:///system --auto-resize=always --domain-name "Win10" &
            exit
        fi
    elif [[ $1 == "start-pt" ]]
    then
        virsh --connect qemu:///system list | grep -q -w 'Win10'
        IS_WIN10_RUNNING=$?
        if [[ $IS_WIN10_RUNNING == 0 ]]
        then
            echo "First use: ${0##*/} stop"
            exit
        else
            virsh --connect qemu:///system start "Win10PT" 2>/dev/null
            sleep 30 && remmina -c "${HOME}/.local/share/remmina/group_rdp_win10pt_172-16-1-111.remmina" &
            exit
        fi
    fi
    echo "Use: ${0##*/} start|start-pt|stop|deploy|backup"
fi
