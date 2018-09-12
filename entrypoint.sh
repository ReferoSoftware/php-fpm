#! /bin/sh

_APP_DIR=${APP_DIR:-/opt/app-root}
_LISTEN_HOST=${LISTEN_HOST:-127.0.0.1}
_LISTEN_PORT=${LISTEN_PORT:-9000}
chown -R 1001:1001 $_APP_DIR

# Replace the configurable host and port by replacing the 
sed -e "s/__LISTEN_PORT__/$_LISTEN_PORT/g" /usr/etc/php-fpm.d/www.conf.template |\
	sed -e "s/__LISTEN_HOST__/$_LISTEN_HOST/g" \
	> /usr/etc/php-fpm.d/www.conf

# The readiness probe is explained in the readme
if [ -f $_APP_DIR/readiness-probe ]; then
	chmod +x $_APP_DIR/readiness-probe

	$_APP_DIR/readiness-probe

	if [ $? -ne 0 ]; then
		echo 'The application is not ready, and could not be started';
		exit 1;
	fi
fi

# This is required so we can change the command that is run when starting up
# i.e. `docker run php-fpm "php ./some-script.php"`
if [ "$#" -gt "0" ]; then
	$@
	exit "$?"
fi

php-fpm