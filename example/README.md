# Example: Multi-Cloud between AWS and Google Cloud with Consul PacketFabric CTS module

This example demonstrates how to set up a multi-cloud network connection between AWS and Google Cloud Platform using PacketFabric's Cloud Router, Consul for service discovery, and the Consul Terraform Sync (CTS) module for network automation.

:warning: **For simplicity, we starts the Consul agent in development mode. This mode is useful for bringing up a single-node Consul environment quickly and easily. It is not intended to be used in production as it does not persist any state.**

## Before you begin

- Before you begin we recommend you read about the [Terraform basics](https://www.terraform.io/intro)
- Don't have a PacketFabric Account? [Get Started](https://docs.packetfabric.com/intro/)
- Don't have an AWS Account? [Get Started](https://aws.amazon.com/free/)
- Don't have a Google Account? [Get Started](https://cloud.google.com/free)

## Prerequisites

Ensure you have installed the following prerequisites:

- [Git](https://git-scm.com/downloads)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [jq](https://stedolan.github.io/jq/download/)
- [python3](https://www.python.org/downloads/)

Ensure you have the following items available:

- [AWS Account ID](https://docs.aws.amazon.com/IAM/latest/UserGuide/console_account-alias.html)
- [AWS Access and Secret Keys](https://docs.aws.amazon.com/general/latest/gr/aws-security-credentials.html)
- [Google Service Account](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances)
- [PacketFabric Billing Account](https://docs.packetfabric.com/api/examples/account_uuid/)
- [PacketFabric API key](https://docs.packetfabric.com/admin/my_account/keys/)

## Quick start

1. Set the PacketFabric API key and Account ID in your terminal as environment variables.

```sh
export PF_TOKEN="secret"
export PF_ACCOUNT_ID="123456789"
```

Set additional environment variables for AWS and Google:

```sh
### AWS
export PF_AWS_ACCOUNT_ID="98765432"
export AWS_ACCESS_KEY_ID="ABCDEFGH"
export AWS_SECRET_ACCESS_KEY="secret"

### Google
export TF_VAR_gcp_project_id="my-project-id" # used for bash script used with gcloud module
export GOOGLE_CREDENTIALS='{ "type": "service_account", "project_id": "demo-setting-1234", "private_key_id": "1234", "private_key": "-----BEGIN PRIVATE KEY-----\nsecret\n-----END PRIVATE KEY-----\n", "client_email": "demoapi@demo-setting-1234.iam.gserviceaccount.com", "client_id": "102640829015169383380", "auth_uri": "https://accounts.google.com/o/oauth2/auth", "token_uri": "https://oauth2.googleapis.com/token", "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs", "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/demoapi%40demo-setting-1234.iam.gserviceaccount.com" }'

export TF_VAR_public_key="ssh-rsa AAAA...= user@mac.lan" # used to create to access to the demo instances in AWS/Google
export TF_VAR_my_ip="1.2.3.1/32" # replace with your public IP address (used in AWS/Google security groups)
```

2. Initialize Terraform, create an execution plan and execute the plan.

```sh
terraform init
terraform plan
```

**Note:** you can update terraform variables in the ``variables*.tf``.

3. Apply the plan:

```sh
terraform apply
```

4. Review the configuration

Connect to the Consul server in your browser `http://<aws_ec2_public_ip_server>:8500/ui`

SSH to the Consul server using `ubuntu` user (then `sudo su -`) and look at the log `cat  /var/log/cloud-init-output.log` and run `consul members` to confirm

Example:
```
root@ip-10-2-1-15:~# consul members
Node       Address          Status  Type    Build   Protocol  DC   Partition  Segment
agent-one  10.2.1.15:8301   alive   server  1.15.2  2         dc1  default    <all>
```

5. Now, let's create a new nginx demo service in AWS, edit `aws_ec2_consul_client_nginx.tf` and comment out its content, then run terraform apply

```sh
terraform plan
terraform apply
```

6. Back on the Consul demo server, run `consul members` and confirm the new node has been added. You can also look on `http://<aws_ec2_public_ip_server>:8500/ui`.

Example:
```
root@ip-10-2-1-15:~# consul members
Node       Address          Status  Type    Build   Protocol  DC   Partition  Segment
agent-one  10.2.1.15:8301   alive   server  1.15.2  2         dc1  default    <all>
nginx-aws  10.2.1.220:8301  alive   client  1.15.2  2         dc1  default    <default>
```

Because we configure CTS to create a connection between AWS and Google when a service called `nginx-demo-aws` was being discovered, a PacketFabric Cloud Router to connect both clouds will be created (this operation can take up to 30min).

You can check the CTS status with:
```
curl -s localhost:8558/v1/status | jq .
curl -s localhost:8558/v1/tasks | jq .
```

You can also login to [PacketFabric](https://portal.packetfabric.com/) to follow the progress.

**Note:** You can find the Terraform state file in `/home/ubuntu/sync-tasks/packetFabric-cloud-router/.terraform/`.

7. Once the connection between AWS and Google Cloud is established, let's wait for the service to register automatically to the Consul server.

Back on the Consul demo server, run `consul members` and confirm the new node has been added. 

Example:
```
root@ip-10-2-1-15:~# consul members
Node       Address          Status  Type    Build   Protocol  DC   Partition  Segment
agent-one      10.2.1.15:8301   alive   server  1.15.2  2         dc1  default    <all>
nginx-aws      10.2.1.220:8301  alive   client  1.15.2  2         dc1  default    <default>
nginx-google   10.5.1.20:8301  alive   client  1.15.2  2         dc1  default    <default>
```

8. You can test connectivity between AWS and Google by navigating to `http://<aws_ec2_public_ip_server>:8089/` and simulate traffic between the 2 nginx servers.

**Note:** Default login/password for Locust is ``demo:packetfabric``. Use Private IP of the consul client nodes.

9. Now, let's remove the node from the Consul server, destroy the PacketFabric Cloud Router.

```
consul force-leave -prune nginx-aws
```

10. Confirm the PacketFabric Cloud Router has been deleted and the `nginx-aws` isn't registered anymore in Consul and everything has been removed in AWS and Google (especially the AWS Direct Connect Gateway Associations which can take up to 20min to be removed).

11. Destroy the rest of the demo infra.

```sh
terraform destroy
```

## Troubleshooting

Login on the Consul server node and tail `/var/log/cloud-init-output.log`.