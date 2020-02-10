#!/bin/sh

chmod +x pxedeploy.sh
chmod +x ClonezillaInstall
pkg install -y sudo nano bash dnsmasq ipxe samba410
./pxedeploy.sh
