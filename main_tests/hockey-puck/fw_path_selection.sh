#!/bin/bash

read -p "Is this an IS or Non-IS board? (Type 'IS' or 'Non-IS'): " BOARD_TYPE
BOARD_TYPE=$(echo "$BOARD_TYPE" | tr '[:upper:]' '[:lower:]')
case "$BOARD_TYPE" in
    is)
        echo "/home/analog/production-tests/main_tests/hockey-puck/hockey_puck-non-os-is-TCP 1.hex"
        ;;
    non-is)
        echo "/home/analog/production-tests/main_tests/hockey-puck/hockey_puck-non-os-non-is-TCP.hex"
        ;;
    *)
        echo "Invalid option. Please type 'IS' or 'Non-IS'."
        exit 1
        ;;
esac