FROM ubuntu:latest
MAINTAINER Michael COULLERET <michael.coulleret@vesperiagroup.com>

RUN apt-get update

# Install MySQL
RUN apt-get install -y mysql-server mysql-client libmysqlclient-dev

# Install Apache
RUN apt-get install -y apache2

# Install PHP
RUN apt-get install -y php5 php5-cli php5-readline php5-intl php5-cli php5-json php5-mongo php5-mysql php5-curl php5-dev php-pear
RUN pecl install -o -f xdebug

# Install expect
RUN apt-get install -y expect

# Add template
ADD ./template/apache2.conf /etc/apache2/apache2.conf
ADD ./template/symfony.conf /etc/apache2/sites-available/symfony.conf
ADD ./template/php.ini /etc/php5/apache2/
ADD ./template/mongo.ini /usr/local/etc/php/conf.d/

# a2enmod & a2ensite
RUN a2enmod php5
RUN a2enmod rewrite
RUN a2ensite symfony.conf

RUN mkdir -p /vhost/current/
VOLUME /vhost/current/
RUN usermod -u 1000 www-data
RUN chown -R www-data:www-data /vhost/current/

RUN sed -i "s/;date.timezone =.*/date.timezone = Europe\/Paris/" /etc/php5/apache2/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = Europe\/Paris/" /etc/php5/cli/php.ini

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/apache2/symfony_access.log
RUN ln -sf /dev/stderr /var/log/apache2/symfony_error.log

# Port
EXPOSE 80

ADD bootstrap.sh /bootstrap.sh
RUN chmod 755 /bootstrap.sh
CMD ["/bootstrap.sh"]
