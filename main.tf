terraform {
  required_providers {
    packetfabric = {
      source  = "PacketFabric/packetfabric"
      version = ">= 1.6.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.62.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 4.61.0"
    }
  }
  required_version = ">= 1.1.0, < 1.3.0"
  experiments      = [module_variable_optional_attrs] # until consul-terraform-sync supports terraform v1.3+
}

provider "aws" {
  # we have to set it to something in case no aws connections are defined
  region = var.aws_cloud_router_connections != null ? var.aws_cloud_router_connections.aws_region : "us-east-1"
}

module "packetfabric" {
  for_each = var.services
  source   = "packetfabric/cloud-router-module/connectivity"
  version  = "0.3.0"
  # PacketFabric Cloud Router
  name     = var.name
  cr_id    = var.cr_id
  asn      = var.asn
  capacity = var.capacity
  regions  = var.regions
  labels   = concat(var.labels, [each.value.name]) # add the service name to the labels
  # PacketFabric Cloud Router Connection to Google
  google_cloud_router_connections = var.google_cloud_router_connections
  # PacketFabric Cloud Router Connection to AWS
  aws_cloud_router_connections = var.aws_cloud_router_connections
  # PacketFabric Cloud Router Connection to Azure
  azure_cloud_router_connections = var.azure_cloud_router_connections
}

locals {
  # Creating a map with key as service name instead of service id
  service_names = transpose({
    for id, s in var.services : id => [s.name]
  })
}