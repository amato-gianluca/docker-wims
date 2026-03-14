#!/bin/bash

if [ -f /home/wims/log/logo.jpeg ]; then
  cp /home/wims/log/logo.jpeg /home/wims/public_html/logo.jpeg
  chown wims:wims /home/wims/public_html/logo.jpeg
else
  rm -f /home/wims/public_html/logo.jpeg
fi
