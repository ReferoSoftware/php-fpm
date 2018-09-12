FROM openshift/base-centos7

LABEL maintainer="Adam Kirk <adamk@refero.uk>"

# Install php and all its extensions...
RUN yum install -y epel-release
RUN yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
RUN yum install -y yum-utils
RUN yum-config-manager --enable remi-php72
RUN yum update -y
RUN yum install -y php72
RUN yum install -y php-fpm
RUN yum install -y php-cli
RUN yum install -y php-curl
RUN yum install -y php-gd
RUN yum install -y php-mysqlnd
RUN yum install -y php-pgsql
RUN yum install -y php-mbstring
RUN yum install -y php-xml
RUN yum install -y php-sqlite3
RUN yum install -y php-memcached
RUN yum install -y php-imap
RUN yum install -y php-zip

# Required for wkhtmltopdf
RUN yum install -y libpng
RUN yum install -y libjpeg
RUN yum install -y openssl
RUN yum install -y icu
RUN yum install -y libX11
RUN yum install -y libXext
RUN yum install -y libXrender
RUN yum install -y xorg-x11-fonts-Type1
RUN yum install -y xorg-x11-fonts-75dpi

# Install wkhtmltopdf
RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN unxz wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN tar -xvf wkhtmltox-0.12.4_linux-generic-amd64.tar
RUN mv wkhtmltox/bin/* /usr/local/bin/
RUN rm -rf wkhtmltox
RUN rm -f wkhtmltox-0.12.4_linux-generic-amd64.tar

# Cleanup some files...probably needs to be more thorough
RUN yum clean all -y

COPY php-fpm.conf php.ini /etc/
COPY php-fpm.d/* /usr/etc/php-fpm.d/

RUN chown 1001:1001 /etc/php-fpm.conf /etc/php.ini
RUN chown -R 1001:1001 /usr/etc/php-fpm.d

# Add a custom entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chown 1001:1001 /entrypoint.sh
RUN chmod +x /entrypoint.sh

# This default user is created in the openshift/base-centos7 image
USER 1001

ENTRYPOINT ["/entrypoint.sh"]
