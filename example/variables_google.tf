## Google VARs
variable "gcp_project_id" {
  type        = string
  description = "Google Cloud project ID"
}
# https://cloud.google.com/compute/docs/regions-zones
variable "gcp_region1" {
  type        = string
  default     = "us-west1"
  description = "Google Cloud region"
}
variable "gcp_zone1" {
  type        = string
  default     = "us-west1-a"
  description = "Google Cloud zone"
}
variable "gcp_subnet_cidr1" {
  type        = string
  description = "CIDR for the subnet"
  default     = "10.5.1.0/24"
}

# PacketFabric Cloud Router Connection - Google
variable "google_pop" {
  type        = string
  description = "The POP in which you want to provision the connection"
  default     = "PDX2"
}