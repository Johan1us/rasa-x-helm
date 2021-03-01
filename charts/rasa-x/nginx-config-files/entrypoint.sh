#!/bin/bash

# Run original bitnami `entrypoint.sh` first
# https://github.com/bitnami/bitnami-docker-nginx/blob/483f0abb3ee3dbaff57ea154cb5c10ef5e064111/1.17/debian-10/Dockerfile#L35
/opt/bitnami/scripts/nginx/entrypoint.sh

if [[ ! -f /opt/bitnami/nginx/conf/bitnami/terms/agree.txt ]]
then
  echo "you have not agreed to the terms and conditions, Rasa X cannot start. To accept the terms and conditions run echo \"\$\{USER\} \$\(date\)\" > /opt/bitnami/nginx/conf/bitnami/terms/agree.txt on the host machine. You can find the terms at https://storage.googleapis.com/rasa-x-releases/rasa_x_ce_license_agreement.pdf"
  exit 1
fi

cp /tmp/rasax.nginx /tmp/ssl.conf /opt/bitnami/nginx/conf/conf.d
cp /tmp/nginx.conf /opt/bitnami/nginx/conf/nginx.conf

if [[ ! -e "/opt/bitnami/certs/fullchain.pem" ]] || [[ ! -e "/opt/bitnami/certs/privkey.pem" ]]
then
  echo "SSL encryption is not used since no certificates were provided."
  # comment out ssl since the user did not provide certificates
  sed -i '\,include[[:blank:]]*/opt/bitnami/nginx/conf/conf.d/ssl.conf;,s,^,#,g' /opt/bitnami/nginx/conf/conf.d/rasax.nginx
fi

# exec CMD
echo ">> exec docker CMD"
echo "$@"
exec "$@"
