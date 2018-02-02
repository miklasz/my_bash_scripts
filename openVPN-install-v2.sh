#!/bin/bash

function log {
  echo "=> $1"  >&2
}
log ""
log "Install packages for Open VPN"
log ""
apt-get update && apt-get install -y     \
    openvpn              \
    uuid                 \
  dnsutils             \
  nginx-light             \
  easy-rsa             \
  openssl

MY_IP_ADDR=$(dig @ns1.google.com -t txt o-o.myaddr.l.google.com +short | sed 's/"//g')
log ""
log "IP detected: $MY_IP_ADDR"
log ""
UUID=$(uuid)
log""
log "Update motd"
log ""
cat <<EOFMOTD > /etc/update-motd.d/70-openvpn
#!/bin/sh
echo ""
echo "_______________________________________________________________________________________________"
echo "Download the VPN configuration here:"
echo "http://$MY_IP_ADDR:8003/$UUID/$HOSTNAME.ovpn"
echo ""
echo "And add it to your openvpn client."
echo ""
echo "apt-get remove nginx-light to disable the HTTP server."
echo "And remove this file with rm /etc/update-motd.d/70-openvpn"
EOFMOTD
chmod 755 /etc/update-motd.d/70-openvpn
log ""
log "enable forwarding"
log ""
echo 1 > /proc/sys/net/ipv4/ip_forward
log ""
log "create required directory"
log ""
log "/etc/openvpn"
log "/etc/openvpn/easy-rsa"
log "/etc/openvpn/easy-rsa/keys/"
log ""
mkdir -p /etc/openvpn/
mkdir -p /etc/openvpn/easy-rsa/
mkdir -p /etc/openvpn/easy-rsa/keys/
log ""
log "Copy easy-rsa to /etc/openvpn/easy-rsa"
log ""
cp -r /usr/share/easy-rsa/ /etc/openvpn/
log ""
log "source vars data"
log ""
export KEY_COUNTRY="UK"
export KEY_PROVINCE="Manchester"
export KEY_CITY="Manchester"
export KEY_ORG="Bartron"
export KEY_EMAIL="aqq@aqq.pl"
export KEY_OU="Bartron"
export KEY_NAME="server"
log ""
log "Create dh key "
log ""
openssl dhparam -out /etc/openvpn/dh2048.pem 2048
log ""
log "clean old keys if exists"
log ""
cd /etc/openvpn/easy-rsa/ && ./clean-all
log ""
log "read vars"
log ""
# easy-rsa parameter settings

# NOTE: If you installed from an RPM,
# don't edit this file in place in
# /usr/share/openvpn/easy-rsa --
# instead, you should copy the whole
# easy-rsa directory to another location
# (such as /etc/openvpn) so that your
# edits will not be wiped out by a future
# OpenVPN package upgrade.

# This variable should point to
# the top level of the easy-rsa
# tree.
export EASY_RSA="`pwd`"

#
# This variable should point to
# the requested executables
#
export OPENSSL="openssl"
export PKCS11TOOL="pkcs11-tool"
export GREP="grep"


# This variable should point to
# the openssl.cnf file included
# with easy-rsa.
export KEY_CONFIG=`$EASY_RSA/whichopensslcnf $EASY_RSA`

# Edit this variable to point to
# your soon-to-be-created key
# directory.
#
# WARNING: clean-all will do
# a rm -rf on this directory
# so make sure you define
# it correctly!
export KEY_DIR="$EASY_RSA/keys"

# Issue rm -rf warning
echo NOTE: If you run ./clean-all, I will be doing a rm -rf on $KEY_DIR

# PKCS11 fixes
export PKCS11_MODULE_PATH="dummy"
export PKCS11_PIN="dummy"

# Increase this to 2048 if you
# are paranoid.  This will slow
# down TLS negotiation performance
# as well as the one-time DH parms
# generation process.
export KEY_SIZE=2048

# In how many days should the root CA key expire?
export CA_EXPIRE=3650

# In how many days should certificates expire?
export KEY_EXPIRE=3650

# These are the default values for fields
# which will be placed in the certificate.
# Don't leave any of these fields blank.

# PKCS11 Smart Card
# export PKCS11_MODULE_PATH="/usr/lib/changeme.so"
# export PKCS11_PIN=1234

# If you'd like to sign all keys with the same Common Name, uncomment the KEY_CN export below
# You will also need to make sure your OpenVPN server config has the duplicate-cn option set
# export KEY_CN="CommonName"
log ""
log "build ca"
log ""
cd /etc/openvpn/easy-rsa/ && ./build-ca
log ""
log "build server key"
log ""
cd /etc/openvpn/easy-rsa/ && ./build-key-server server
log ""
log "move server keys to /etc/openvpn"
log ""
cd /etc/openvpn/easy-rsa/keys && cp server.crt server.key ca.crt /etc/openvpn/
log ""
log "build personal key and move to ~/bartron-key/"
log ""
cd /etc/openvpn/easy-rsa/ && ./build-key bartron
mkdir /root/bartron-key/
cd /etc/openvpn/easy-rsa/keys && cp bartron.crt bartron.key ca.crt /root/bartron-key/
log ""
log "create .ovpn file"
log ""
log "Create client configuration"
cat <<EOFCLIENT > ~/bartron-key/bartron-vpn.ovpn
client
nobind
comp-lzo
dev tun
<key>
`cat /root/bartron-key/bartron.key`
</key>
<cert>
`cat /root/bartron-key/bartron.crt`
</cert>
<ca>
`cat /root/bartron-key/ca.crt`
</ca>
<dh>
`cat /etc/openvpn/dh2048.pem`
</dh>
<connection>
remote $MY_IP_ADDR 1194 udp
</connection>
EOFCLIENT

cat <<EOFUDP > /etc/openvpn/udp1194.conf
server 172.16.253.0 255.255.255.0
verb 3
duplicate-cn
comp-lzo
key key.pem
ca cert.pem
cert cert.pem
dh dh.pem
keepalive 10 60
persist-key
persist-tun
proto udp
port 1194
dev tun1194
status openvpn-status-1194.log
log-append /var/log/openvpn-udp1194.log
EOFUDP

echo "Setup HTTP server for serving client certificate"
mkdir -p /usr/share/nginx/openvpn/$UUID
cp /root/bartron-key/bartron-vpn.ovpn /usr/share/nginx/openvpn/$UUID/$HOSTNAME.ovpn
touch /usr/share/nginx/openvpn/$UUID/index.html
touch /usr/share/nginx/openvpn/index.html

cat <<EOFNGINX > /etc/nginx/sites-available/openvpn
server {
    listen 8003;
    root /usr/share/nginx/openvpn;
}
EOFNGINX

[ -f /etc/nginx/sites-enabled/openvpn ] || ln -s /etc/nginx/sites-available/openvpn /etc/nginx/sites-enabled/
service nginx stop
service nginx start

log "Restart OpenVPN"

set +e
service openvpn stop
service openvpn start
log ""
log "###################################################################"
log ""
log "Download http://$MY_IP_ADDR:8003/$UUID/$HOSTNAME.ovpn to setup your OpenVPN client after rebooting the server"
log ""
log ""
log "Make sure your firewall rules allow VPN"
log ""
log "Reboot system to enable OpenVPN"
log ""
log ""
