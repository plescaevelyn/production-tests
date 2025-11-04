#!/bin/bash

SCRIPT_DIR="$(readlink -f $(dirname $0))"

source $SCRIPT_DIR/../lib/utils.sh
echo "This test is for hockey-puck board"

MODE="$1"

case $MODE in
    "Firmware and memory test")
    echo_blue "Programming production test firmware..."
    FW_PATH=$SCRIPT_DIR/hp_testing_fw.hex
    $SCRIPT_DIR/firmware_p.sh "$FW_PATH" &&
    echo_blue "Memory testing..."
    tty=/dev/ttyACM0
    stty -F $tty 115200
    exec 4<$tty 5>$tty
    read -p "Power cycle the ADIN1100 board and then press ENTER"
    timeout 10s $SCRIPT_DIR/memory_test.sh
    TEST_RESULT=$?
    echo $TEST_RESULT
    if [ $TEST_RESULT -ne 0 ]; then
        handle_error_state "$BOARD_SERIAL"
        exit 1
    fi
    ;;

    "MAXQ Provisioning")
    echo_blue "Flashing USS_provisioning..."
    FW_HEX="$SCRIPT_DIR/USS_provisioning.hex"
    $SCRIPT_DIR/firmware_p.sh "$FW_HEX"
    TEST_RESULT=$?
    if [ $TEST_RESULT -ne 0 ]; then
        handle_error_state "$BOARD_SERIAL"
        exit 1
    fi
    ;;

    "Final Firmware")
    echo_blue "Flashing final firmware..."
    FW_PATH="$("$SCRIPT_DIR/fw_path_selection.sh")"
    echo "Selected firmware: $FW_PATH"
    $SCRIPT_DIR/firmware_p.sh "$FW_PATH"
    echo_blue "Pinging the board..."
    tty=/dev/ttyACM0
    stty -F $tty 115200
    exec 4<$tty 5>$tty
    read -p "Power cycle the ADIN1100 board and then press ENTER"
    $SCRIPT_DIR/ping.sh
    TEST_RESULT=$?
    echo $TEST_RESULT
    if [ $TEST_RESULT -ne 0 ]; then
        handle_error_state "$BOARD_SERIAL"
        exit 1
    fi
    ;;

    *) echo "Invalid option $MODE" ;;

esac
