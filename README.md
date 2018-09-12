# PHP-FPM

A php-fpm docker image designed to run on the openshift container platform.

---

## www.conf.template

If you look in `./php-fpm.d/www.conf.template` you'll notice that it uses an odd listen directive, something like `listen = __LISTEN_HOST__:__LISTEN_PORT__`. It is created this way so that this image is portable, we should be able to run this image in almost any environment by configuring two corresponding environment variables. Before the php-fpm process is started, the `./php-fpm.d/www.conf.template` file is run through a simple sed script which replaces the corresponding placeholders with the supplied environment variables. See the `./entrypoint.sh` script to see how this is done.

The pattern to use this is very simple, remove the prefixed and suffixed '__' from the placeholder name and that is the name of the environment variable you need to supply to override the property.

---

## Configurable environment variables

This image is aware of the following environment variables:

| Environment variable | Default value   | Description |
|----------------------|-----------------|-------------|
| `LISTEN_HOST`        | `127.0.0.1`     | Changes the host in listen directive for php-fpm to the supplied value. |
| `LISTEN_PORT`        | `9000`          | Changes the port in the listen directive for php-fpm to the supplied value. |
| `APP_DIR`            | `/opt/app-root` | This is only really required if you want to use a readiness probe. It should be the directory where you have placed the application code. |

All of these variables will be replaced (where applicable) before starting the php-fpm process.

---

## Readiness probe

_This is still in beta and will be fine tuned in the near future_

The readiness probe is designed to avoid race conditions in a highly dynamic container environment. In a normal situation, the application should not assume that all the services it depends on are ready at the time of starting this container. Ever used the official mysql or postgres image in a docker-compose environment? It takes a small while for the containers to initialise and accept connections, the readiness probe in the application is beneficial for teo reasons:
- It gives the devs complete control over how to run this probe, with no change to infrastructure
- It keeps our infrastructure definition files clean from inline bash scripting etc.

The entrypoint file will automatically detect this and run the script. 

### Requirements

This file should be a shell executable `/bin/sh`, please see `./example/_readiness-probe` for an example script.

There is only really one requirement, it should return a relevant exit code. This is the norm in bash, if the check was successful and all services could be successfully connected to, return '0' else return any other code.

---

## Openshift container engine

This image is designed to run on the openshift container engine, which is the primary reason it extends the `openshift/base-centos7` image as opposed to the official `php:fpm-*` distributions. The main restriction this places upon the image is the user and file permissions, please see the openshift documentation to learn more about writing images for use in that ecosystem.

---

## Testing

Currently there are no tests for this container...bad I know. I will add a test that should not rely on a webserver such as NGiNX and will however bind directly to php-fpm and execute a simple php script. This will require some 'interesting' scripting to install the `cgi-fcgi` package in another container, something like this:

```bash
$ SCRIPT_FILENAME=/path/to/site/index.php \
REQUEST_METHOD=GET \
cgi-fcgi -bind -connect ${LISTEN_HOST}:${LISTEN_PORT}
```

This will ensure we can test, separately from the http server, that php-fpm is serving requests correctly, and we could potentially use this method for load testing php-fpm in isolation from the http server. 