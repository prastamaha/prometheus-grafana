#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo 'Please run as sudo or root user'
    exit
fi

prometheus_check=$(systemctl is-active prometheus_server.service)

if [ $prometheus_check = active ]; then
  echo 'Prometheus server DETECTED'
else
  echo 'Prometheus server is not detected'
  echo 'install Prometheus server with this command: ./prometheus-2.15.2.sh'
  exit
fi


echo 'LOG: Download alertManager package'
cd /opt
wget https://github.com/prometheus/alertmanager/releases/download/v0.20.0/alertmanager-0.20.0.linux-amd64.tar.gz
tar xvfz alertmanager-0.20.0.linux-amd64.tar.gz
cd alertmanager-0.20.0.linux-amd64

echo "======================================================================================="
echo 'note: use gmail, please active "Less secure app access". use this link: https://myaccount.google.com/lesssecureapps'
read -p 'email : ' email_from
read -ps 'password : ' email_pass
read -p 'send to : ' email_send

resolve_timeout=10s

read -p 'resolve timeout, default[10s] : ' $resolve_timeout

cat > config.yml << EOF
global:
  resolve_timeout: $resolve_timeout

route:
  group_by: [Alertname]
  receiver: email-me

receivers:
- name: email-me
  email_configs:
  - to: "$email_send"
    from: "$email_from"
    smarthost: smtp.gmail.com:587
    auth_username: "$email_from"
    auth_identity: "$email_from"
    auth_password: "$email_pass"
    send_resolved: True

EOF

echo 'LOG: Create alertmanager service into /etc/systemd/system/alert_manager.service'
ip_addr=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')

cat > /etc/systemd/system/alert_manager.service << EOF
[Unit]
Description=Alert Manager

[Service]
User=root
ExecStart=/opt/alertmanager-0.20.0.linux-amd64/alertmanager --config.file=/opt/alertmanager-0.20.0.linux-amd64/config.yml --web.external-url=http://$ip_addr:9093/

[Install]
WantedBy=default.target

EOF

echo 'LOG: check config.yml'
./amtool check-config config.yml

echo 'LOG: enable and start alermanager service'
systemctl daemon-reload
systemctl enable alert_manager.service
systemctl start alert_manager.service
#systemctl status alert_manager.service

state=$(systemctl is-active alert_manager.service)

if [ $state = active ]; then
    echo
    echo '=================================='
    echo 'ALERT MANAGER INSTALL SUCCESSFULLY' 
    echo '=================================='
    echo 
    echo 'Alert manager dasboard : http://'$ip_addr':9093'
    echo
else
    echo
    echo '============================'
    echo 'ALERT MANAGER INSTALL FAILED' 
    echo '============================'
    echo
fi