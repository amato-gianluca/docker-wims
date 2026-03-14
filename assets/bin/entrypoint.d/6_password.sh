#!/bin/bash

if [ -n "$WIMS_PASS" ]; then   
    echo "$WIMS_PASS" > /home/wims/log/.wimspass
    chown wims:wims /home/wims/log/.wimspass
    chmod 600 /home/wims/log/.wimspass
fi
