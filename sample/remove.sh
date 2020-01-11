#!/bin/bash

if [ "#EUID" -ne 0 ]; then
    echo 'Please run as Root'
    exit
fi

echo 'LOG: Uninstall grafana'
apt-get purge grafana -y

echo 'LOG: Uninstall Prometheus server'
apt-get purge prometheus prometheus-node-exporter -y

echo "LOG: Remove grafana repository '/etc/apt/sources.list.d/grafana.list'"
rm /etc/apt/sources.list.d/grafana.list

echo 'LOG: Update repository'
apt-get Update -y

echo 'LOG: Remove junk file with autoremove'
apt-get autoremove -y

echo 
echo '====================='
echo 'UNINSTALL SUCCESSFULLY'
echo '====================='
