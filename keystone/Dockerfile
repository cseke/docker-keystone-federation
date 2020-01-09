FROM python:2.7.17-buster

EXPOSE $KEYSTONE_PORT
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
    apache2 \
    libapache2-mod-shib2 \
    libldap2-dev libsasl2-dev \
    libapache2-mod-wsgi git vim memcached less \
    libffi-dev python-dev libssl-dev mariadb-client libssl-dev \
    && apt-get -y clean

ARG keystone_version
RUN git clone -b "$keystone_version" https://github.com/openstack/keystone.git
RUN git clone -b "$keystone_version" https://github.com/openstack/requirements

RUN useradd --user-group keystone \
    && pip install -e /keystone -c /requirements/upper-constraints.txt \
    && pip install -e /keystone mechanicalsoup

RUN pip install pbr PyMySQL python-memcached python-openstackclient python-ldap ldappool -c /requirements/upper-constraints.txt \
    && mkdir -p /etc/keystone/credential-keys /var/www/cgi-bin/keystone /var/log/apache2 /home/keystone \
    && cp -r /keystone/etc/* /etc/keystone/

RUN apt-get install -y ldap-utils && pip install pydevd lxml
RUN shib-keygen -y 10

ADD ./bootstrap /home/keystone/bootstrap
COPY ./etc/keystone/keystone.ini /etc/keystone/keystone.conf
COPY ./etc/mod_shibboleth/shibboleth2.xml /etc/shibboleth/shibboleth2.xml
COPY ./etc/apache2/keystone.conf /etc/apache2/sites-available/
COPY ./etc/mod_shibboleth/attribute-map.xml /etc/shibboleth/attribute-map.xml
COPY wait-for-it.sh /wait-for-it.sh
COPY token.py /token.py

RUN chown -R keystone: /etc/keystone /var/www/cgi-bin/keystone /var/log/apache2 /home/keystone \
    && chown -R _shibd:_shibd  /etc/shibboleth/* \
    && chown -R _shibd:_shibd  /etc/shibboleth/ \
    && chmod 777 /etc/shibboleth/shibboleth2.xml

RUN echo "ServerName $HOSTNAME" >> /etc/apache2/apache2.conf
