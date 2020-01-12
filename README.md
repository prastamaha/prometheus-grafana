# **Prometheus with Grafana Installer**

This script uses version:
prometheus      : 2.15.2
node_exporter   : 6.5.2
grafana         : 0.18.1
alert manager   : 0.20.0

all of the script must be run with sudo or root user


## **Use Case Example**

__Topology:__ 

![](images/Prometheus-grafana-ex.png)

## **Clone Repository**

    cd $HOME
    git clone https://github.com/prastamaha/prometheus-grafana.git

## **SERVER B**

### _Node Exporter Installation_

    cd $HOME/prometheus-grafana
    sudo ./node_exporter.sh

check node exporter metric : http://$SERVER_B_IP_ADDR:9100

## **SERVER A**

### __Prometheus Installation__

prometheus script by default will install node_exporter.service in localhost

    cd $HOME/prometheus-grafana
    sudo ./prometheus-2.15.2.sh

check prometheus dasboard : http://$SERVER_A_IP_ADDR:9090

### __Grafana Installation__

    cd $HOME/prometheus-grafana
    sudo ./grafana-6.5.2.sh

check grafana dasboard : http://$SERVER_A_IP_ADDR:3000

you can import grafana dasboard templete which exists in :

    cd $HOME/prometheus-grafana/grafana-dashboard

### __Alert Manager Installation__

_NOTE: Please use gmail account for this installation_

Your google account must actived "Less secure app access"

use this link: [https://myaccount.google.com/lesssecureapps](https://myaccount.google.com/lesssecureapps)
    
    cd $HOME/prometheus-grafana
    sudo ./alertmanager.sh

### __Alert Manager Rules: Instance Down__

this script will config an alert manager rules for sending notice to your email if there is a down instance based on the _job-name_

    cd $HOME/prometheus-grafana/alertmanager-rules
    sudo ./instanceDown.sh






    


