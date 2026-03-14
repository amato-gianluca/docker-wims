#!/bin/bash

config_file=/home/wims/log/wims.conf

if [ ! -f "$config_file" ]; then
    echo "threshold1=$(($(grep -c processor /proc/cpuinfo) * 150))" > "$config_file"
    echo "threshold2=$(($(grep -c processor /proc/cpuinfo) * 300))" >> "$config_file"
    chown wims:wims "$config_file"
    chmod go-rwx "$config_file"

    if [ -n "$MANAGER_SITE" ]; then
        if [ "$MANAGER_SITE" = "auto" ]; then
            echo "manager_site=$(route -n | grep "UG" | awk '{print $2}')" >> "$config_file"
        else
            echo "manager_site=$MANAGER_SITE" >> "$config_file"
        fi
    fi
fi
