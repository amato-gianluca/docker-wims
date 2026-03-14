#!/bin/bash

# Scripts under post-install.d/ will be processed only during docker image building.
#
# These scripts may use the APP_ENV variable to check whether they should be executed in
# test and/or production environments.
#
# Do not check APP_ENV variable value if it has to be run always.
#
# These scripts will be processed after WIMS has been compiled and before concluding
# the Dockerfile. It is a proper place to customize apache settings and whatever
# content within the docker image when extending it.
#
for action in "$(dirname "$0")"/post-install.d/*.sh; do
  # For debugging purposes.
  echo "[POST-INSTALL] Processing $action..."
  # Start it in a subprocess, to be protected against unintentional exit commands.
  ("$action")
done
