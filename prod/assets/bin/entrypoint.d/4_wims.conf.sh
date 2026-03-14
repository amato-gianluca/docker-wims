#!/bin/bash

config_file=/home/wims/log/wims.conf
ncpus=$(grep -c processor /proc/cpuinfo)

id

# For all environments: create required wims.conf file if missing.
if [ ! -f "$config_file" ]; then
  echo "threshold1=$((ncpus * 150))" > "$config_file"
  echo "threshold2=$((ncpus * 300))" >> "$config_file"
else
  # Update threshold values, just in case the number of CPU/vCPU has changed since last boot.
  threshold1=$((ncpus * 150))
  sed -i "s/threshold1=.*/threshold1=$threshold1/g" "$config_file"
  threshold2=$((ncpus * 300))
  sed -i "s/threshold2=.*/threshold2=$threshold2/g" "$config_file"
fi

# Invariant: we must be sure of these permissions, or we cannot enter into administration.
chown wims:wims "$config_file"
chmod go-rwx "$config_file"
