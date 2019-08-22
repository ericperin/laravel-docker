FROM ubuntu:18.04

RUN apt-get update && apt-get install -y software-properties-common

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Install PHP
RUN add-apt-repository ppa:ondrej/php -y && apt-get update
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install php7.1 php7.1-dev php7.1-xml -y --allow-unauthenticated

# Install prerequisites
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# Ubuntu 18.04
RUN curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17

# Install the PHP drivers for Microsoft SQL Server
# RUN pecl install sqlsrv
# RUN pecl install pdo_sqlsrv
RUN su
RUN printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/7.1/mods-available/sqlsrv.ini
RUN printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/7.1/mods-available/pdo_sqlsrv.ini
RUN exit
RUN phpenmod -v 7.1 sqlsrv pdo_sqlsrv

# Install Apache and configure driver loading
RUN su
RUN apt-get install -y libapache2-mod-php7.3 apache2
RUN a2dismod mpm_event
RUN a2enmod mpm_prefork
RUN a2enmod php7.1
RUN exit

# Restart Apache and test the sample script
RUN service apache2 restart