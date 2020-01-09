# Docker-keystone-federation

Containerized Openstack Keystone federation dev-environment.


----------
## Components: ##

  - Shibboleth as Idp
  - OpenLDAP as idendity storage.
  - Openstack Keystone + mod_shibd as SP


![Containers Schema](https://image.ibb.co/fnQUva/Screenshot_from_2017_03_20_11_19_08.png)



----------

## How start to use:

#### 0) Prerequisites:

Install docker and docker-compose (1.25.1) (eg: `pip3 install docker-compose --user`)

#### 1) Start containers:

* `docker-compose -f docker-compose-idp.yaml up`
* `docker-compose -f docker-compose-keystones.yaml up`

```
   Name                  Command               State                   Ports                  
----------------------------------------------------------------------------------------------
database       docker-entrypoint.sh mysqld      Up      3306/tcp
idp            java -Didp.home=/opt/shibb ...   Up      443/tcp, 80/tcp, 0.0.0.0:443->8443/tcp
keystone       /bin/sh -c /bin/bash -x ./ ...   Up      0.0.0.0:5000->5000/tcp
ldap           /container/tool/run              Up      389/tcp, 636/tcp
phpldapadmin   /container/tool/run              Up      443/tcp, 80/tcp
```

#### 2) During `keystone` container starting an initialization script creates federation stuff like groups, projects, mappings, etc. To change default behaivor take a look at:

- `keystone/bootstrap/keystone/init-federation.sh`

#### 3) To verify that all is ok, try to get unscoped token via Idp SSO (use browser):

`http://192.168.200.6:5000/v3/OS-FEDERATION/identity_providers/shibboleth/protocols/saml2/auth`

 - Password to everything: `r00tme`.
 - Existing users (stored in LDAP): `dm` and `admin`

#### 4) Also you can try to get scoped token via SAML2 ECP (non-browsing access) using next openrc:

Keystone

```
#!/bin/bash
export OS_AUTH_TYPE="v3samlpassword"
export OS_IDENTITY_API_VERSION=3
export OS_PROJECT_DOMAIN_NAME="default"
export OS_IDENTITY_PROVIDER="shibboleth"
export OS_IDENTITY_PROVIDER_URL="http://idp/idp/profile/SAML2/SOAP/ECP"
export OS_USERNAME="dm"
export OS_PASSWORD="r00tme"
export OS_AUTH_URL="http://keystone:5000/v3"
export OS_PROTOCOL="saml2"
```

```
source openrc && openstack token issue
```

Keystone2

```
#!/bin/bash
export OS_AUTH_TYPE="v3samlpassword"
export OS_IDENTITY_API_VERSION=3
export OS_PROJECT_DOMAIN_NAME="default"
export OS_IDENTITY_PROVIDER="shibboleth"
export OS_IDENTITY_PROVIDER_URL="http://idp/idp/profile/SAML2/SOAP/ECP"
export OS_USERNAME="dm"
export OS_PASSWORD="r00tme"
export OS_AUTH_URL="http://keystone2:5001/v3"
export OS_PROTOCOL="saml2"
```

```
source openrc && openstack token issue
```


> If you get an error such as “Missing value identity-provider-url required for auth plugin v3samlpassword” or if you do not see “v3samlpassword” listed in “–os-auth-type” when running “openstack –help”, you need to install “lxml” into your available Python packages (eg: “pip install lxml”)

## Notes:

#### o /etc/host file on Host

Add to `/etc/hosts`

```
192.168.200.4 idp
192.168.200.2 ldap
192.168.200.6 keystone
192.168.200.7 keystone2
```

#### o Known issue

> Could not find Identity Provider: shibboleth.: IdentityProviderNotFound: Could not find Identity Provider: shibboleth.

` keystone/bootstrap/keystone/init-federation.sh` script execution failed, just login to container (`docker exec -it keystone /bin/bash`) and execte it manually (/home/keystone/bootstrap/keystone/init-federation.sh)


## How OpenStack Keystone Federation works ?
One of the services that OpenStack Keystone provides is `Identity Service`:
 
![Keystone Services](https://www.safaribooksonline.com/library/view/identity-authentication-and/9781491941249/assets/image013.png)
 
But there are some cases when people need to re-use existen `Identity Provider` in a company (e.g. Shibboleth or or even Facebook SSO) and delegate a AuthN operations from Keystone to it. This allows users to use the same credentials across all environment. In terms of SAML protocol the Keystone acts as `Service Provider` which trusts to one or more `Identity Providers`.
In this case as result of a AuthN procedure on `Identity Provider` side, the users achive a `SAML assertion`, which describe and verifying a user as they login. A assertion signed by Identity Provider and can be consumed by OpenStack Keystone to give a token which based on information in assertion.

![](http://7xp2eu.com1.z0.glb.clouddn.com/artifact%20binding.png?imageView2/1/w/600/h/400/q/100)

Using OpenStack Keystone mapping mechanism an administrator relying on information from SAML assertion can assign to a federated user the local for a Openstack Envirtonment projects, roles and groups.


## References:
- https://joscor.com/blog/use-openstack-cli-with-saml-2-0-ecp/
- https://github.com/kbespalov/docker-keystone-federation (source)