#!/bin/bash

## This script is used to flash the firmware to hockey-puck board using the DAPLink interface.

SCRIPT_DIR="$(readlink -f $(dirname $0))"
source $SCRIPT_DIR/../lib/utils.sh

exec 3>&1 4>&2
exec 1>/dev/null 2>/dev/null

FW_PATH=${1:-}

if [[ -z "$FW_PATH" ]]; then
    echo "Usage: $0 <firmware_path>" >&3
    exit 1
fi

daplink_mount=$(ls -d /media/root/DAPLINK* 2>/dev/null | sort -V | tail -n 1)
mountpoint=$(mount | awk -v path="$daplink_mount" '$0 ~ path { for (i=1; i<=NF; i++) if ($i ~ path) print $i }')
if [ -z "$mountpoint" ]; then
    echo "No mountpoint found for DAPLINK" >&3
    exit 1
fi
echo "Mountpoint: $mountpoint" >&3

inotifywait -m -e unmount "$mountpoint" | (
    rsync -ahv --progress "$FW_PATH" "$mountpoint"
    sync

    while read -r directory event filename; do
        echo "$mountpoint has been unmounted. Waiting for it to be mounted again..." >&3
        start_time=$(date +%s)
        while true; do
            if mountpoint -q "$mountpoint"; then
                echo "$mountpoint has been remounted." >&3
                pkill -P $$ inotifywait  # Send SIGTERM to child inotifywait process
                break
            fi
            current_time=$(date +%s)
            elapsed_time=$((current_time - start_time))
            if [ "$elapsed_time" -ge 30 ]; then
                echo "Timeout reached. $mountpoint did not remount within 30 seconds." >&3
                pkill -P $$ inotifywait  # Send SIGTERM to child inotifywait process
                break
            fi
            sleep 1  # Adjust the interval as needed
        done
    done
)

if [[ -f "${mountpoint}/FAIL.txt" ]]; then
    echo "FAILED" >&3
else
    echo "no fail.txt found. SUCCESS" >&3
fi
