name   = "demo-cts-standalone"
labels = ["terraform-cts", "nginx"]

aws_cloud_router_connections = [
  {
    name       = "packetfabric-cts-aws"
    aws_region = "us-east-1"
    aws_vpc_id = "vpc-bea401c4"
    aws_pop    = "NYC1" # https://packetfabric.com/locations/cloud-on-ramps
  }
]

google_cloud_router_connections = [
  {
    name           = "packetfabric-cts-google"
    google_project = "demo-setting-1234"
    google_region  = "us-west1"
    google_network = "default"
    google_pop     = "SFO1" # https://packetfabric.com/locations/cloud-on-ramps
  }
]

azure_cloud_router_connections = [
  {
    name                  = "packetfabric-cts-azure"
    azure_region          = "North Central US"
    azure_resource_group  = "MyResourceGroup"
    azure_vnet            = "MyVnet"
    azure_pop             = "Chicago" # https://docs.microsoft.com/en-us/azure/expressroute/expressroute-locations-providers
    azure_subscription_id = "00000000-0000-0000-0000-000000000000"
  }
]