#!/bin/bash

# cleanup
unset `env | grep OS_ | awk -F '=' '{print $1}'| xargs`

export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=r00tme
export OS_AUTH_URL=http://keystone_url:admin_port_id/v3
export OS_IDENTITY_API_VERSION=3
