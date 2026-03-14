#!/bin/bash

# Scripts under actions/ paths have APP_ENV available to check whether they
# should be executed in this case. Do not check APP_ENV if a script must always
# run, regardless of whether it is a production or testing environment.
for action in "$(dirname "$0")"/entrypoint.d/*.sh; do
  # For debugging purposes.
  echo "[ENTRYPOINT] Processing $action..."
  # Start it in a subprocess, to be protected against unintentional exit commands.
  ("$action")
done

# Execute always this step in the end to keep the container working.
apachectl -D FOREGROUND
