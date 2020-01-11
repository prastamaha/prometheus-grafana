#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo 'Please run as sudo or root user'
    exit
fi

$node_exporter=y
read -p 'install node exporter in this server ( default[y] ) ? yes[y], no[n] : ' node_exporter

if [ $node_exporter = y ]; then
    echo 'LOG: Installing Node Exporter'
    ./node_exporter.sh
elif [ $node_exporter = n ]; then
    echo 'LOG: Node Exporter do not installed'
else
    echo 'LOG: Installing Node Exporter'
    ./node_exporter.sh
fi

ip_addr=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')

echo 'LOG: Download prometheus packages, placed into /opt'
cd /opt
wget https://github.com/prometheus/prometheus/releases/download/v2.10.0/prometheus-2.10.0.linux-amd64.tar.gz

echo 'LOG: Extract prometheus packages'
tar xvfz prometheus-2.10.0.linux-amd64.tar.gz
cd prometheus-2.10.0.linux-amd64

echo 'LOG: Create config.yml file'
read -p 'job name : ' job_name
read -p 'node exporter ip address: ' node_exporter_ip_addr

cat > config.yml << EOF
global:
  scrape_interval:     15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus-server'
    static_configs:
    - targets: ['$ip_addr:9090']
  - job_name: '$job_name'
    static_configs:
    - targets: ['$ip_addr:9100','$node_exporter_ip_addr:9100']

EOF

echo 'LOG: check config'
./promtool check config config.yml

echo 'LOG: create prometheus service into /etc/systemd/system/prometheus_server.service'
cat > /etc/systemd/system/prometheus_server.service << EOF
[Unit]
Description=Prometheus Server

[Service]
User=root
ExecStart=/opt/prometheus-2.10.0.linux-amd64/prometheus --config.file=/opt/prometheus-2.10.0.linux-amd64/config.yml --web.external-url=http://$ip_addr:9090/

[Install]
WantedBy=default.target

EOF

echo 'LOG: Enable and start prometheus service'

systemctl daemon-reload
systemctl enable prometheus_server.service
systemctl start prometheus_server.service
#systemctl status prometheus_server.service

state=$(systemctl is-active prometheus_server.service)

if [ $state = active ]; then
    echo
    echo '==============================='
    echo 'PROMETHEUS INSTALL SUCCESSFULLY' 
    echo '==============================='
    echo 
    echo 'Prometheus dasboard : http://'$ip_addr':9090'
    if [ $node_exporter = y ]; then
        echo 'local node exporter : http://'$ip_addr':9100'
    fi
else
    echo
    echo '========================='
    echo 'PROMETHEUS INSTALL FAILED' 
    echo '========================='
fi