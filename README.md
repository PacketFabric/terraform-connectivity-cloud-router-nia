[![Release](https://img.shields.io/github/v/release/PacketFabric/terraform-connectivity-cloud-router-nia?display_name=tag)](https://github.com/PacketFabric/terraform-connectivity-cloud-router-nia/releases)
![release-date](https://img.shields.io/github/release-date/PacketFabric/terraform-connectivity-cloud-router-nia)
![contributors](https://img.shields.io/github/contributors/PacketFabric/terraform-connectivity-cloud-router-nia)
![commit-activity](https://img.shields.io/github/commit-activity/m/PacketFabric/terraform-connectivity-cloud-router-nia)
[![License](https://img.shields.io/github/license/PacketFabric/terraform-connectivity-cloud-router-nia)](https://github.com/PacketFabric/terraform-connectivity-cloud-router-nia)

## PacketFabric Cloud Router module for Network Infrastructure Automation (NIA) 

This Terraform [Consul Terraform Sync](https://www.consul.io/docs/nia) module enables users to seamlessly create, update, and delete [PacketFabric Cloud Routers](https://docs.packetfabric.com/cr/), which can be used to connect AWS and Google Cloud networks.

By leveraging [Consul](https://www.consul.io) catalog information, this module offers dynamic management of the Cloud Router, allowing application teams to quickly establish multi-cloud connectivity without the need for manual IT or networking tickets.

With the PacketFabric Cloud Router CTS module, application teams can easily add (or remove) connections between AWS and Google Cloud VPCs via the secure and reliable [PacketFabric's Network-as-a-Service platform](https://packetfabric.com/). This module streamlines the establishment of connections, the creation of Cloud Routers, and the integration of essential components for both AWS and Google Cloud.

<p align="left">
  <img src="https://raw.githubusercontent.com/PacketFabric/terraform-connectivity-cloud-router-nia/main/images/diagram_cloud_router_aws_google_consul.png" alt="Diagram illustrating the connectivity between AWS, Google Cloud, and Consul using a PacketFabric Cloud Router">
</p>

## Feature

This module enables the creation of a PacketFabric Cloud Router, along with either a standalone or redundant connections to AWS and Google Clouds. It automates the creation of an AWS Direct Connect with a Private Virtual Interface (VIF), as well as a Google VLAN Attachment and a Google Cloud Router.

To get started with the module, users need to provide a minimum set of information, including the cloud provider regions, credentials, as well as VPC names and IDs. 

If you would like to see support for other cloud service providers (e.g. Azure, Oracle, IBM, etc.), please open an issue on [GitHub](https://github.com/PacketFabric/terraform-connectivity-cloud-router-nia/issues) to share your suggestions or requests.

## Requirements

### Ecosystem Requirements

| Ecosystem | Version |
|-----------|---------|
| [consul](https://www.consul.io/downloads) | >= 1.7 |
| [consul-terraform-sync](https://www.consul.io/docs/nia) | >= 1.15 |
| [terraform](https://www.terraform.io) | ">= 1.1.0, < 1.3.0" |

### Terraform Providers

| Name | Version |
|------|---------|
| [PacketFabric Terraform Provider](https://registry.terraform.io/providers/PacketFabric/packetfabric) | >= 1.5.0 |
| [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest) | >= 4.62.0 |
| [Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest) | >= 4.61.0 |

### Terraform Module

| Name | Version |
|------|---------|
| [PacketFabric Terraform Cloud Router Module](https://registry.terraform.io/modules/PacketFabric/cloud-router-module/connectivity/0.1.0) | = 0.1.0 |

### Before you begin

- Before you begin we recommend you read about the [Terraform basics](https://www.terraform.io/intro) and [Consul](https://developer.hashicorp.com/consul/tutorials)
- Don't have a PacketFabric Account? [Get Started](https://docs.packetfabric.com/intro/)
- Don't have an AWS Account? [Get Started](https://aws.amazon.com/free/)
- Don't have a Google Account? [Get Started](https://cloud.google.com/free)

### Prerequisites

Ensure you have installed the following prerequisites:

- [Git](https://git-scm.com/downloads)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

Ensure you have the following items available:

- [AWS Account ID](https://docs.aws.amazon.com/IAM/latest/UserGuide/console_account-alias.html)
- [AWS Access and Secret Keys](https://docs.aws.amazon.com/general/latest/gr/aws-security-credentials.html)
- [Google Service Account](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances)
- [PacketFabric Billing Account](https://docs.packetfabric.com/api/examples/account_uuid/)
- [PacketFabric API key](https://docs.packetfabric.com/admin/my_account/keys/)

### Prerequisites

Ensure you have installed the following prerequisites:

- [Git](https://git-scm.com/downloads)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [Consul](https://developer.hashicorp.com/consul/downloads)

## Setup

1. Make sure you enabled Compute Engine API in Google Cloud
2. Create Google Service Account along wih the Private Key
3. Create an AWS Access Key and Secret Access Key
4. Create a PacketFabric API Key
5. Gather necessary information such as AWS account ID, Google and AWS regions, VPC name (Google), VPC ID (AWS), Google Project ID and [PacketFabric Cloud On-Ramps](https://packetfabric.com/locations/cloud-on-ramps) (PoP) and create your custom variable file (see examples `example-standalone.tfvars` and `example-redundant.tfvars`)
6. Customize your Consul Terraform Sync

Environement variables needed:

```sh
### PacketFabric
export PF_TOKEN="secret"
export PF_ACCOUNT_ID="123456789"
### AWS
export PF_AWS_ACCOUNT_ID="98765432"
export AWS_ACCESS_KEY_ID="ABCDEFGH"
export AWS_SECRET_ACCESS_KEY="secret"
### Google
export GOOGLE_CREDENTIALS='{ "type": "service_account", "project_id": "demo-setting-1234", "private_key_id": "1234", "private_key": "-----BEGIN PRIVATE KEY-----\nsecret\n-----END PRIVATE KEY-----\n", "client_email": "demoapi@demo-setting-1234.iam.gserviceaccount.com", "client_id": "102640829015169383380", "auth_uri": "https://accounts.google.com/o/oauth2/auth", "token_uri": "https://oauth2.googleapis.com/token", "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs", "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/demoapi%40demo-setting-1234.iam.gserviceaccount.com" }'
```

## Usage

| Input Variable | Required | Default | Description |
|----------------|----------|----------|------------|
| name                      | Yes      | | The base name all Network services created in PacketFabric, Google and AWS |
| labels                    | No       | terraform-cts | The labels to be assigned to the PacketFabric Cloud Router and Cloud Router Connections |
| asn                       | No       | 4556 | The Autonomous System Number (ASN) for the PacketFabric Cloud Router |
| capacity                  | No        | "10Gbps" | The capacity of the PacketFabric Cloud Router |
| regions                   | No       | ["US"] | The list of regions for the PacketFabric Cloud Router (["US", "UK"]) |
| aws_cloud_router_connections | Yes     | | A list of objects representing the AWS Cloud Router Connections (Private VIF) |
| google_cloud_router_connections | Yes  | | A list of objects representing the Google Cloud Router Connections |
<!-- | azure_cloud_router_connections | Yes  | | A list of objects representing the Azure Cloud Router Connections | -->

**Note**: Only one object for `google_cloud_router_connections` and `aws_cloud_router_connections` can be defined.

:warning: **Please be aware that creating AWS Cloud Router connections can take up to 30 minutes due to the gateway association operation.**

### AWS

**Note**: Note that the default Maximum Transmission Unit (MTU) is set to `1500` in both AWS and Google.

#### Private VIF

| Input Variable | Required | Default | Description |
|----------------|----------|----------|------------|
| aws_region | Yes | | The AWS region |
| aws_vpc_id | Yes | | The AWS VPC ID |
| aws_asn1 | No | 64512 | The AWS ASN for the first connection |
| aws_asn2 | No | 64513 | The AWS ASN for the second connection if redundant |
| aws_pop | Yes | | The [PacketFabric Point of Presence](https://packetfabric.com/locations/cloud-on-ramps) for the connection |
| aws_speed | No | 1Gbps | The connection speed |
| redundant | No | false | Create a redundant connection if set to true |
| bgp_prefixes | No | VPC network subnets | List of supplementary [BGP](https://docs.packetfabric.com/cr/bgp/reference/) prefixes - must already exist as established routes in the routing table associated with the VPC |
| bgp_prefixes_match_type | No | exact | The BGP prefixes match type exact or orlonger for all the prefixes |

**Note**: This module currently supports private VIFs only. If you require support for transit or public VIFs, please feel free to open [GitHub Issues](https://github.com/PacketFabric/terraform-connectivity-cloud-router-nia/issues) and provide your suggestions or requests.

### Google

| Input Variable | Required | Default | Description |
|----------------|----------|----------|------------|
| google_project | Yes | | The Google Cloud project ID |
| google_region | Yes | | The Google Cloud region |
| google_network | Yes | | The Google Cloud VPC network name |
| google_asn | No | 16550 | The Google Cloud ASN |
| google_pop | Yes | | The [PacketFabric Point of Presence](https://packetfabric.com/locations/cloud-on-ramps) for the connection |
| google_speed | No | 1Gbps | The connection speed |
| redundant | No | false | Create a redundant connection if set to true |
| bgp_prefixes | No | VPC network subnets | List of supplementary [BGP](https://docs.packetfabric.com/cr/bgp/reference/) prefixes - must already exist as established routes in the routing table associated with the VPC |
| bgp_prefixes_match_type | No | exact | The BGP prefixes match type exact or orlonger for all the prefixes |

### User Config for Consul Terraform Sync

example.hcl
```hcl
consul {
  address = "${consul}:8500"
}

log_level = "info" # debug

task {
  name           = "PacketFabric-Cloud-Router-AWS-Google"
  description    = "Automate multi-cloud connectivity with Consul services"
  module         = "packetfabric/cloud-router-nia/connectivity"
  version        = "0.1.0"
  providers      = ["packetfabric", "aws", "google"]
  condition "services" {
    names = ["nginx"]
  }
  variable_files = ["example-standalone.tfvars"]
}

driver "terraform" {
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
```

## Support Information

This repository is community-supported. Follow instructions below on how to raise issues.

### Filing Issues and Getting Help

If you come across a bug or other issue, use [GitHub Issues](https://github.com/PacketFabric/terraform-connectivity-cloud-router-nia/issues) to submit an issue for our team. You can also see the current known issues on that page, which are tagged with a purple Known Issue label.

## Copyright

Copyright 2023 PacketFabric, Inc.

### PacketFabric Contributor License Agreement

Before you start contributing to any project sponsored by PacketFabric, Inc. on GitHub, you will need to sign a Contributor License Agreement (CLA).

If you are signing as an individual, we recommend that you talk to your employer (if applicable) before signing the CLA since some employment agreements may have restrictions on your contributions to other projects. Otherwise by submitting a CLA you represent that you are legally entitled to grant the licenses recited therein.

If your employer has rights to intellectual property that you create, such as your contributions, you represent that you have received permission to make contributions on behalf of that employer, that your employer has waived such rights for your contributions, or that your employer has executed a separate CLA with PacketFabric.

If you are signing on behalf of a company, you represent that you are legally entitled to grant the license recited therein. You represent further that each employee of the entity that submits contributions is authorized to submit such contributions on behalf of the entity pursuant to the CLA.