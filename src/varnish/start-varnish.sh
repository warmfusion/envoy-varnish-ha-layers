#!/bin/bash

echo "Creating $1.vcl based on DNS results for $2"
/opt/varnish/dns-to_backend.sh $1 $2 > /etc/varnish/$1.vcl


echo "Setting up look for updating configuration..."
while /bin/true; do
  /opt/varnish/dns-to_backend.sh $1 $2 > /etc/varnish/$1.vcl
  /usr/share/varnish/reload-vcl -q
  sleep 60
done &


# Generate secret for varnish
dd if=/dev/random of=/etc/varnish_secret count=1 2>&1 > /dev/null


DAEMON=/usr/sbin/varnishd

# Maximum number of open files (for ulimit -n)
NFILES=131072

# Maximum locked memory size (for ulimit -l)
# Used for locking the shared memory log in memory.  If you increase log size,
# you need to increase this number as well
MEMLOCK=82000

DAEMON_OPTS="-a :6081 \
             -T localhost:6082 \
             -f /etc/varnish/default.vcl \
             -S /etc/varnish_secret \
             -s malloc,256m \
             -F"

# Open files (usually 1024, which is way too small for varnish)
ulimit -n ${NFILES:-131072}

# Maxiumum locked memory size for shared memory log
ulimit -l ${MEMLOCK:-82000}

echo "Starting Varnish"
${DAEMON} ${DAEMON_OPTS} 2>&1