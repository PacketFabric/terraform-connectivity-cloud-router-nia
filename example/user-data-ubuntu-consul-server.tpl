#!/usr/bin/env bash
set -x

user="ubuntu"

# Update /etc/environment with the required variables
echo 'PF_TOKEN="${PF_TOKEN}"' | sudo tee -a /etc/environment
echo 'PF_ACCOUNT_ID="${PF_ACCOUNT_ID}"' | sudo tee -a /etc/environment
echo 'PF_AWS_ACCOUNT_ID="${PF_AWS_ACCOUNT_ID}"' | sudo tee -a /etc/environment
echo 'AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"' | sudo tee -a /etc/environment
echo 'AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"' | sudo tee -a /etc/environment
echo "GOOGLE_CREDENTIALS='$(echo ${GOOGLE_CREDENTIALS} | base64 --decode)'" | sudo tee -a /etc/environment

export PF_TOKEN=${PF_TOKEN}
export PF_ACCOUNT_ID=${PF_ACCOUNT_ID}
export PF_AWS_ACCOUNT_ID=${PF_AWS_ACCOUNT_ID}
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
export GOOGLE_CREDENTIALS=$(echo ${GOOGLE_CREDENTIALS} | base64 --decode)

# add consul repo
sudo curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
# install nginx and consul
sudo apt-get update
sudo apt-get -y install consul net-tools tree consul-terraform-sync jq
# disable firewall
sudo ufw disable
# start consul server
ip=$(ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -f1 -d'/')
nohup consul agent -server -bootstrap-expect=1 \
    -data-dir=/tmp/consul -node=agent-one -bind=$ip \
    -enable-script-checks=true -config-dir=/etc/consul.d -client 0.0.0.0 -ui &

mkdir /etc/consul.d/cts-packetfabric

sudo cat <<EOT > /etc/consul.d/cts-packetfabric/packetfabric-cloud-router.tfvars
name = "packetfabric-cts"

aws_cloud_router_connections = [
  {
    name       = "packetfabric-cts-aws"
    aws_region = "${aws_region}"
    aws_vpc_id = "${aws_vpc_id}"
    aws_pop    = "${aws_pop}"
  }
]

google_cloud_router_connections = [
  {
    name            = "packetfabric-cts-google"
    google_project  = "${google_project}"
    google_region   = "${google_region}"
    google_network  = "${google_network}"
    google_pop      = "${google_pop}"
  }
]
EOT

sudo cat <<EOT > /etc/consul.d/cts-packetfabric/cts-config.hcl
consul {
  address = "localhost:8500"
}

log_level = "debug" # info

working_dir = "sync-tasks"
port        = 8558

syslog {}

buffer_period {
  enabled = true
  min     = "5s"
  max     = "20s"
}

driver "terraform" {
  log         = true
  persist_log = true

  backend "consul" {
    gzip = true
  }

  required_providers {
    packetfabric = {
      source  = "PacketFabric/packetfabric"
    }
    aws = {
      source  = "hashicorp/aws"
    }
    google = {
      source  = "hashicorp/google"
    }
  }
}

task {
  name           = "packetFabric-cloud-router"
  description    = "Automate multi-cloud connectivity with Consul services"
  module         = "packetfabric/cloud-router-nia/connectivity"
  version        = "0.3.0"
  providers      = ["packetfabric", "aws", "google"]
  condition "services" {
    names = ["nginx-demo-aws"]
  }
  variable_files = ["/etc/consul.d/cts-packetfabric/packetfabric-cloud-router.tfvars"]
}

terraform_provider "packetfabric" {
   task_env {
    "PF_TOKEN" = "{{ env \"PF_TOKEN\" }}"
    "PF_ACCOUNT_ID" = "{{ env \"PF_ACCOUNT_ID\" }}"
    "GOOGLE_CREDENTIALS" = "{{ env \"GOOGLE_CREDENTIALS\" }}"
    "AWS_ACCESS_KEY_ID" = "{{ env \"AWS_ACCESS_KEY_ID\" }}"
    "AWS_SECRET_ACCESS_KEY" = "{{ env \"AWS_SECRET_ACCESS_KEY\" }}"
  }
}

terraform_provider "google" {
   task_env {
    "GOOGLE_CREDENTIALS" = "{{ env \"GOOGLE_CREDENTIALS\" }}"
  }
}

terraform_provider "aws" {
   task_env {
    "AWS_ACCESS_KEY_ID" = "{{ env \"AWS_ACCESS_KEY_ID\" }}"
    "AWS_SECRET_ACCESS_KEY" = "{{ env \"AWS_SECRET_ACCESS_KEY\" }}"
  }
}
EOT

sleep 60

echo;echo
cd /home/ubuntu
consul-terraform-sync start -config-file /etc/consul.d/cts-packetfabric/cts-config.hcl # -inspect -once

echo;echo
consul validate /etc/consul.d
echo;echo
consul version
echo;echo
consul members
echo;echo
curl -s localhost:8558/v1/status | jq .
echo;echo
curl -s localhost:8558/v1/tasks | jq .