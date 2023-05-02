name     = "demo-redundant"
labels   = ["terraform-cts", "nginx"]
asn      = 4556
capacity = "10Gbps"

aws_cloud_router_connections = {
  aws_region = "us-east-1"
  aws_vpc_id = "vpc-bea401c4"
  aws_asn1   = 64512
  aws_asn2   = 64513
  aws_pop    = "NYC1"
  aws_speed  = "2Gbps"
  redundant  = true
  bgp_prefixes = [
    {
      prefix = "10.0.0.0/8"
      type   = "out"
    },
    {
      prefix = "172.16.0.0/16"
      type   = "in"
    },
  ]
}

google_cloud_router_connections = {
  google_project = "demo-setting-1234"
  google_region  = "us-west1"
  google_network = "default"
  google_asn     = 16550
  google_pop     = "SFO1"
  google_speed   = "1Gbps"
  redundant      = true
  bgp_prefixes = [
    {
      prefix = "172.16.0.0/16"
      type   = "out"
    },
    {
      prefix = "10.0.0.0/8"
      type   = "in"
    },
  ]
}