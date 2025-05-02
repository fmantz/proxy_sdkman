#!/bin/sh
# ----------------------------------------------------------------------------
# entrypoint for squid container
# ----------------------------------------------------------------------------

# Remove old process id:
rm /usr/local/squid/var/run/squid.pid

SQUID_VERSION=$(/usr/local/squid/sbin/squid -v | grep Version | awk '{ print $4 }')
echo "Staring squid [${SQUID_VERSION}]"

# init squid once:
export MARKER_FILE=/usr/local/squid/var/cache/swap.state
if [ ! -f "$MARKER_FILE" ]; then
  echo "Init Squid-Cache..."
  /usr/local/squid/libexec/security_file_certgen -c -s /usr/local/squid/var/logs/ssl_db -M 20
  /usr/local/squid/sbin/squid -z
else 
	echo "Squid-Cache was already init before."
fi

sleep 5
# run squid in foreground and afterwards add write access for all users:
# -d 10 is the log level, which is very explicit
/usr/local/squid/sbin/squid -N -d 10
