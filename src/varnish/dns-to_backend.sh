#!/bin/sh
# Usage;
# $0 'name' 'domain_lookup.com'
set -e

backend_file="$(mktemp)"
subinit_file="$(mktemp)"

cat >"$subinit_file" <<EOF
sub vcl_init {
    new $1 = directors.round_robin();
EOF


# dig -t A +noquestion +nocomments +nostats +nocmd "$2" |   # We don't have dig.. use getent
# getent hosts $2 | awk '{ print $1 }' |

IPS=$(python -c "import socket;print socket.getaddrinfo(\"$2\",'http')[0][4][0]")


echo $IPS |awk '{print $NF}' |
sort |
while read ip
do
    be="$1_$(printf %s "$ip" | tr . _)"

	cat >>"$backend_file" <<-EOF
	backend $be {
	    .host = "$ip";
	}

	EOF

	cat >>"$subinit_file" <<-EOF
	    $1.add_backend($be);
	EOF
done

echo "}" >>"$subinit_file"

cat "$backend_file" "$subinit_file"
rm -f "$backend_file" "$subinit_file"