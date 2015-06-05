#!/bin/sh

CID=`sudo docker run -e LDAP_ORGANISATION="Code 4 Health" -e LDAP_DOMAIN="code4health.org" -e LDAP_ADMIN_PASSWORD="devpassword" -d osixia/openldap:0.10.1`
IP=`sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CID`
echo $CID - $IP
echo Waiting for LDAP to boot
sleep 5
ldapadd -x -h $IP -D cn=admin,dc=code4health,dc=org -w devpassword -f initial_schemas.ldif
echo installed posix schemas.
echo LDAP_HOST=$IP LDAP_DN=dc=code4health,dc=org LDAP_PASSWORD=devpassword prove -l t/basic_setup.t
LDAP_HOST=$IP LDAP_DN=dc=code4health,dc=org LDAP_PASSWORD=devpassword prove -l t/basic_setup.t
echo ldapsearch -x -h $IP -b dc=code4health,dc=org -D "cn=admin,dc=code4health,dc=org" -w devpassword
ldapsearch -x -h $IP -b dc=code4health,dc=org -D "cn=admin,dc=code4health,dc=org" -w devpassword
