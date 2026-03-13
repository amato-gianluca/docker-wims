#!/bin/bash

if [ "$APP_ENV" != "prod" ];
then
  exit;
fi;

# Only for production site: enable HTTPS forwarding if REVERSE_PROXY variable is set.
# Not for testing environments: usually, local and testing environment will not use HTTPS proxies,
#   but will work on plain HTTP.
rm -f /etc/apache2/conf-enabled/http-proto.conf
if [ "$REVERSE_PROXY" != "" ]; then
  echo 'SetEnvIf X-Forwarded-Proto "https" HTTPS=on' > /etc/apache2/conf-enabled/http-proto.conf;
  echo 'RemoteIPHeader X-Forwarded-For' >> /etc/apache2/conf-enabled/http-proto.conf;
  echo "RemoteIPInternalProxy $REVERSE_PROXY" >> /etc/apache2/conf-enabled/http-proto.conf;
  echo 'Waiting that reverse proxy is resolvable';
  until getent hosts "$REVERSE_PROXY" > /dev/null; do sleep 5; done
fi;
