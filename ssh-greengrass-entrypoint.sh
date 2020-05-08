#!/bin/sh
cd /
/usr/sbin/sshd &
/bin/sh ./greengrass-entrypoint.sh
while true; do sleep 10000; done
