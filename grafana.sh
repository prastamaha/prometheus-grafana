#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo 'Please run as sudo or root user'
    exit
fi

echo 'LOG: Download grafana packages, placed into /opt'
cd /opt
wget https://dl.grafana.com/oss/release/grafana-6.2.5.linux-amd64.tar.gz 

echo 'LOG: Extract grafana packages'
tar -zxvf grafana-6.2.5.linux-amd64.tar.gz
cd grafana-6.2.5

echo 'LOG: Create grafana service into /etc/systemd/system/grafana.service'
cat > /etc/systemd/system/grafana.service << EOF
[Unit]
Description=Grafana

[Service]
User=root
ExecStart=/opt/grafana-6.2.5/bin/grafana-server -homepath /opt/grafana-6.2.5/ web

[Install]
WantedBy=default.target

EOF

echo 'LOG: Enable and start grafana service'
systemctl daemon-reload
systemctl enable grafana.service
systemctl start grafana.service
#systemctl status grafana.service

ip_addr=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
state=$(systemctl is-active grafana.service)

if [ $state = active ]; then
    echo
    echo '============================'
    echo 'GRAFANA INSTALL SUCCESSFULLY' 
    echo '============================'
    echo 
    echo 'Grafana dasboard : http://'$ip_addr':3000'
    echo
else
    echo
    echo '======================'
    echo 'GRAFANA INSTALL FAILED' 
    echo '======================'
    echo
fi