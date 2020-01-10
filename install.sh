#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Please run as Root"
    exit
fi

echo "LOG: Append grafana repository into '/etc/apt/sources.list.d/grafana.list'"
touch /etc/apt/sources.list.d/grafana.list
echo 'deb https://packages.grafana.com/oss/deb stable main' > /etc/apt/sources.list.d/grafana.list

echo "LOG: Update repository"
apt-get update

echo "LOG: Make sure Grafana will be installed from the official repository"
apt-cache policy grafana

echo "LOG: Install Grafana"
sudo apt-get install grafana

echo "LOG: Start and enable Grafana servive"
systemctl start grafana-server
systemctl enable grafana-server

echo "LOG: Install Prometheus and Prometheus Node Exporter"
apt-get install prometheus prometheus-node-exporter

echo "LOG: Start and enable Prometheus service"
systemctl start prometheus
systemctl enable prometheus

echo 
echo '===================='
echo 'INSTALL SUCCESSFULLY'
echo '===================='

IP_ADDR=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
echo
echo 'Grafana dasboard       : http://'$IP_ADDR':3000'
echo 'Prometheus dasboard    : http://'$IP_ADDR':9090'
echo 'Prometheus node metric : http://'$IP_ADDR':9100'
