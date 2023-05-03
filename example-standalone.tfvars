name = "demo-standalone"
labels   = ["terraform-cts", "nginx"]

aws_cloud_router_connections = {
  aws_region = "us-east-1"
  aws_vpc_id = "vpc-bea401c4"
  aws_pop    = "NYC1"
}

google_cloud_router_connections = {
  google_project = "demo-setting-1234"
  google_region  = "us-west1"
  google_network = "default"
  google_pop     = "SFO1"
}