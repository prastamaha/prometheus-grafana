#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo 'Please run as sudo or root user'
    exit
fi

prometheus_check=$(systemctl is-active prometheus_server.service)
alertmanager_check=$(systemctl is-active alert_manager.service)

if [ $prometheus_check = active ] && [ $alertmanager_check = active ]; then
  echo 'Prometheus server and AlertManager DETECTED'
elif [ $prometheus_check = inactive ] && [ $alertmanager_check = active ]; then
  echo 'Prometheus server is not detected'
  echo 'install Prometheus server with this command: ./prometheus-2.15.2.sh'
  exit
elif [ $prometheus_check = active ] && [ $alertmanager_check = inactive ]; then
  echo 'Alert Manager server is not detected'
  echo 'install Alert Manager with this command: ./alertmanager.sh'
  exit
else
  echo 'Prometheus and alert manager server is not detected'
  echo 'install Prometheus server with this command: ./prometheus-2.15.2.sh'
  echo 'install Alert Manager with this command: ./alertmanager.sh'
  exit
fi

cd /opt/prometheus-2.15.2.linux-amd64

echo 'LOG: create a rules for alert when instance down'
read -p 'job name: ' job_name
resolve_timeout=10s
read -p 'resolve timeout, default[10s] : ' $resolve_timeout

cat > node_rules_instance_down.yml << EOF
groups:
- name: node.rules
  rules:
  - alert: InstanceDown
    expr: up{job="$job_name"} == 0
    for: $resolve_timeout
    annotations:
      summary: "Instance {{ \$labels.instance }} down"
      description: "Instance {{ \$labels.instance }} of job {{ \$labels.job }} has been down. Please check it up."

EOF

echo 'LOG: Update prometheus config.yml'
cat >> config.yml << EOF
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - $ip_addr:9093

rule_files:
  - "node_rules_instance_down.yml"

EOF

echo 'LOG: check config.yml'
./promtool check config config.yml

echo 'LOG: restart prometheus_server.service and alert_manager.service'
systemctl restart prometheus_server.service
systemctl restart alert_manager.service

state1=$(systemctl is-active alert_manager.service)
state2=$(systemctl is-active prometheus_server.service)
ip_addr=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')

if [ $state1 = active ] && [ $state2 = active ]; then
    echo
    echo '===================================='
    echo 'ALERT MANAGER RULES SET SUCCESSFULLY' 
    echo '===================================='
    echo 
    echo 'Prometheus alert dasboard : http://'$ip_addr':9090/alerts'
    echo 'Alert manager dasboard    : http://'$ip_addr':9093'
    echo
else
    echo
    echo '=============================='
    echo 'ALERT MANAGER RULES SET FAILED' 
    echo '=============================='
    echo
fi

