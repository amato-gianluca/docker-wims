#!/bin/bash

if [ "$APP_ENV" != "test" ];
then
  exit;
fi;

# Only for testing environment: add local default route IP to enable local administration.
# Not for production sites: You have to define the manager_site list of IPs manually.
#                       Otherwise, all users will see the button for administering WIMS server.
echo "manager_site=$(route -n | grep "UG" | awk '{print $2}')" >> log/wims.conf
