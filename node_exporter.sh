#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo 'Please run as sudo or root user'
    exit
fi

echo 'LOG: Download node exporter package, placed into /opt'
cd /opt
wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz

echo 'LOG: Extract node exporter'
tar xvfz node_exporter-0.18.1.linux-amd64.tar.gz
cd node_exporter-0.18.1.linux-amd64

echo 'Create node exporter service into /etc/systemd/system/node_exporter.service'
cat > /etc/systemd/system/node_exporter.service << EOF
[Unit]
Description=Node Exporter

[Service]
User=root
ExecStart=/opt/node_exporter-0.18.1.linux-amd64/node_exporter

[Install]
WantedBy=default.target

EOF

echo 'LOG: enable and start node exporter service'
systemctl daemon-reload
systemctl enable node_exporter.service
systemctl start node_exporter.service
systemctl status node_exporter.service

state=$(systemctl is-active node_exporter.service)

if [ $state = active ]; then
    echo
    echo '===================='
    echo 'INSTALL SUCCESSFULLY' 
    echo '===================='
else
    echo
    echo '=============='
    echo 'INSTALL FAILED' 
    echo '=============='
fi

