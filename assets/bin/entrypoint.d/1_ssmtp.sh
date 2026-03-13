#!/bin/bash

if [ "$APP_ENV" != "prod" ];
then
  exit;
fi;

# Only for testing environments: quick way of getting emails being sent.
# Not for production sites: you should adapt email sending to your production
#  infrastructure.
SSMTP_MAILHUB=${SSMTP_MAILHUB:-localhost}
cat > /etc/ssmtp/ssmtp.conf <<EOF
mailhub=$SSMTP_MAILHUB
hostname=$SSMTP_HOSTNAME
EOF
