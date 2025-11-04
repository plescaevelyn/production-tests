#!/bin/bash

# Wrapper script for doing a production cycle/routine for HOCKEY-PUCK
# This script handles
#
# Can be called with:  ./production_HOCKEY-PUCK.sh
#

SCRIPT_DIR="$(readlink -f $(dirname $0))"
ScriptLoc="$(readlink -f "$0")"

source $SCRIPT_DIR/lib/production.sh
source $SCRIPT_DIR/lib/utils.sh

while true; do
	echo_blue "Please enter your choice: "
	options=("Firmware and memory test" "MAXQ Provisioning" "Final Firmware" "Power-Off Pi")
	select opt in "${options[@]}"; do
    		case $REPLY in
			1)
				echo_blue "Firmware and memory tests"
				production "crr" "$opt" "HOCKEY-PUCK"
				break ;;
			2)
				echo_blue "MAXQ Provisioning"
				production "crr" "$opt" "HOCKEY-PUCK"
				break ;;
			3) echo_blue "Final Firmware"
				production "crr" "$opt" "HOCKEY-PUCK"
				break ;;
			4)
				enforce_root
				poweroff
				break 2 ;;
			*) echo "invalid option $REPLY";;
    		esac
	done
done
