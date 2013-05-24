#!/bin/bash
logger "user $SUDO_USER: chown -R apache:apache $1"

echo  $PWD | fgrep -q '/opt/example/sites' || echo "this command only works under /opt/example/sites"
echo  $PWD | fgrep -q '/opt/example/sites' || exit
echo "modificando los permisos de $1"
/bin/chown -R apache:apache $1
