name     = "demo-cts-redundant"
labels   = ["terraform-cts", "nginx"]
asn      = 4556
capacity = "10Gbps"

aws_cloud_router_connections = {
  aws_region = "us-east-1"
  aws_vpc_id = "vpc-bea401c4"
  aws_asn1   = 64512
  aws_asn2   = 64513
  aws_pop    = "NYC1" # https://packetfabric.com/locations/cloud-on-ramps
  aws_speed  = "2Gbps"
  redundant  = true
  bgp_prefixes = [ # The prefixes in question must already be present as routes within the route table that is associated with the VPC
    {
      prefix = "10.1.1.0/24"
      type   = "out" # Allowed Prefixes to Cloud (to AWS)
    }
  ]
}

google_cloud_router_connections = {
  google_project = "demo-setting-1234"
  google_region  = "us-west1"
  google_network = "default"
  google_asn     = 16550
  google_pop     = "SFO1" # https://packetfabric.com/locations/cloud-on-ramps
  google_speed   = "1Gbps"
  redundant      = true
  bgp_prefixes = [ # The prefixes in question must already be present as routes within the route table that is associated with the VPC
    {
      prefix = "172.16.1.0/24"
      type   = "out" # Allowed Prefixes to Cloud (to Google)
    }
  ]
}