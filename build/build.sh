#!/bin/sh

cd /build

chmod +x run.sh
mv run.sh /

echo ": RSA htcnet.pem" > /etc/ipsec.secrets
mv htcnet.vpnca.pem /etc/ipsec.d/cacerts
mkdir /data
ln -sf /data/ipsec.conf /etc/ipsec.conf
ln -sf /data/htcnet.cert.pem /etc/ipsec.d/certs
ln -sf /data/htcnet.pem /etc/ipsec.d/private

chmod +x *.sh
mv *.sh /sbin

mv daemons /etc/quagga
cp /usr/share/doc/quagga/examples/ospfd.conf.sample /etc/quagga/ospfd.conf
cp /usr/share/doc/quagga/examples/zebra.conf.sample /etc/quagga/zebra.conf

cd /shadowsocks
python setup.py install