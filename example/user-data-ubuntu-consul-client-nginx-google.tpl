#!/usr/bin/env bash
set -x

user="ubuntu"

# add consul repo
sudo curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
# install nginx and consul
sudo apt-get update
sudo apt-get -y install nginx iperf3 net-tools docker.io docker-compose consul
# make sure nginx is started
sudo service nginx start
# disable firewall
sudo ufw disable
# consul client
sudo cat <<EOT > /etc/consul.d/nginx.json
{
  "service": {
    "name": "nginx-demo-google",
    "tags": ["nginx", "demo", "google"],
    "port": 80,
    "check": {
      "args": ["curl", "localhost"],
      "interval": "10s"
    }
  }
}
EOT
# start consul client
ip=$(ip addr show ens4 | grep 'inet ' | awk '{print $2}' | cut -f1 -d'/')
nohup consul agent -data-dir=/tmp/consul -node=nginx-google \
    -bind=$ip -enable-script-checks=true -config-dir=/etc/consul.d -client 0.0.0.0 -ui &

# custo docker
sudo systemctl unmask docker.service
sudo systemctl unmask docker.socket
sudo systemctl start docker.service
sudo gpasswd -a $user docker

## Locust/Traffic Generator: https://locust.io
mkdir /home/$user/locust
cat <<EOT > /home/$user/locust/locustfile.py
import time
from locust import HttpUser, task, between
# https://docs.locust.io/en/stable/quickstart.html
class QuickstartUser(HttpUser):
    wait_time = between(5, 10)
    @task
    def index_page(self):
        self.client.get("/", verify=False)
EOT

sudo docker run --restart=unless-stopped --name=locust -dit -p 8089:8089 -v /home/$user/locust:/mnt/locust locustio/locust:latest -f /mnt/locust/locustfile.py --host http://10.2.1.x --web-auth demo:packetfabric

end_time=$(date -d "1 hour" +%s)
while [ $(date +%s) -lt $end_time ]; do
  sudo consul join ${consul_server_private_ip} && break
  sleep 30
done