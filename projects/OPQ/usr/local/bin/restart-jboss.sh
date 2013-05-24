#!/bin/sh
service jboss restart
tail -f /opt/example/jboss/server/default/log/*log

