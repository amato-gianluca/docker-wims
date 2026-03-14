#!/bin/bash

SSMTP_MAILHUB=${SSMTP_MAILHUB:-localhost}
cat > /etc/ssmtp/ssmtp.conf <<EOF
mailhub=$SSMTP_MAILHUB
hostname=$SSMTP_HOSTNAME
EOF
