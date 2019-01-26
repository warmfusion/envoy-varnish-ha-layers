#!/bin/bash -x



echo "Creating $1.vcl based on DNS results for $2"
/opt/varnish/dns-to_backend.sh $1 $2 > /etc/varnish/$1.vcl


echo "Setting up look for updating configuration..."
while /bin/true; do
  /opt/varnish/dns-to_backend.sh $1 $2 > /etc/varnish/$1.vcl
  /etc/init.d/varnish reload
  sleep 60
done &


sleep 300

echo "Starting Varnish"
varnishd -f /etc/varnish/user.vcl