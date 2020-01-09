#!/bin/sh

/usr/bin/memcached -u root & >/dev/null || true
sed -i 's/host_name/'"$HOST_NAME"'/' /etc/keystone/keystone.conf
    sed -i 's/{host_name}/'"$HOST_NAME"'/' /home/keystone/bootstrap/mysql/keystone.sql
    sed -i 's/port_id/'"$KEYSTONE_PORT"'/' /etc/apache2/sites-available/keystone.conf
    sed -i 's/keystone_port/'"$KEYSTONE_PORT"'/'  /home/keystone/bootstrap/keystone/openrcs/openrc.sh
    sed -i 's/keystone_url/'"$HOST_NAME"'/'  /home/keystone/bootstrap/keystone/openrcs/openrc.sh
    sed -i 's/keystone_port/'"$KEYSTONE_PORT"'/'  /home/keystone/bootstrap/keystone/openrcs/openrc_federated.sh
    sed -i 's/keystone_url/'"$HOST_NAME"'/'  /home/keystone/bootstrap/keystone/openrcs/openrc_federated.sh
    sed -i 's/keystone_port/'"$KEYSTONE_PORT"'/'  /etc/shibboleth/shibboleth2.xml
    sed -i 's/keystone_url/'"$HOST_NAME"'/'  /etc/shibboleth/shibboleth2.xml

if [ ! -f /bootstraped/$HOST_NAME ]
then
    /bin/bash -x /home/keystone/bootstrap/mysql/init-db.sh

    if [ ! -d /fernet_keys/keys ]; then
        mkdir -p /fernet_keys/keys
        chmod -R 777 /fernet_keys
        keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
        chmod -x /fernet_keys/keys/*
    fi
fi
keystone-manage db_sync
a2ensite keystone
service shibd start
service apache2 restart
if [ ! -f /bootstraped/$HOST_NAME ]
then
    keystone-manage bootstrap \
          --bootstrap-password r00tme \
          --bootstrap-username admin \
          --bootstrap-project-name admin \
          --bootstrap-role-name admin \
          --bootstrap-service-name $HOST_NAME \
          --bootstrap-region-id $REGION \
          --bootstrap-admin-url http://$HOST_NAME:$KEYSTONE_PORT \
          --bootstrap-public-url http://$HOST_NAME:$KEYSTONE_PORT \
          --bootstrap-internal-url http://$HOST_NAME:$KEYSTONE_PORT

    /bin/bash -x /home/keystone/bootstrap/keystone/init-federation.sh
    touch /bootstraped/$HOST_NAME
fi

tail -f /var/log/apache2/keystone.log
