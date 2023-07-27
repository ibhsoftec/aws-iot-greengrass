#!/bin/sh
cd /
/usr/sbin/service ssh start
/bin/sh ./greengrass-entrypoint.sh
while true; do sleep 10000; done
