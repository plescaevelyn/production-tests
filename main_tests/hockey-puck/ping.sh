#!/bin/bash

echo "Ping test in 5s ..."

sleep 5

ping -I eth0 -c3 192.168.0.60
if [ $? -eq 0 ]; then
    RESULT=0;
    exit 0;
else
    RESULT=1;
    exit 1;
fi

