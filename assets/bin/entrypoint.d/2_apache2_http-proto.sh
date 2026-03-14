#!/bin/bash

rm -f /etc/apache2/conf-enabled/http-proto.conf    
if [ "$REVERSE_PROXY" != "" ]; then
    echo 'SetEnvIf X-Forwarded-Proto "https" HTTPS=on' > /etc/apache2/conf-enabled/http-proto.conf
    echo 'RemoteIPHeader X-Forwarded-For' >> /etc/apache2/conf-enabled/http-proto.conf
    echo "RemoteIPInternalProxy $REVERSE_PROXY" >> /etc/apache2/conf-enabled/http-proto.conf
    echo 'Waiting that reverse proxy is resolvable'
    until getent hosts "$REVERSE_PROXY" > /dev/null; do sleep 5; done
fi
