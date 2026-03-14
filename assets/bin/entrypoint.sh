#!/bin/bash

# Scripts under entrypoint.d/ may use APP_ENV to check whether they should
# be executed in test and/or production environments.

for action in "$(dirname "$0")"/entrypoint.d/*.sh; do
  # For debugging purposes.
  echo "[ENTRYPOINT] Processing $action..."
  # Start it in a subprocess, to be protected against unintentional exit commands.
  ("$action")
done

# Execute always this step in the end to keep the container working.
apachectl -D FOREGROUND
