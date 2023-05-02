## General VARs
variable "public_key" {
  type        = string
  description = "Public Key used to access demo Virtual Machines."
  sensitive   = true
}

variable "my_ip" {
  type        = string
  description = "Source Public IP for AWS/Google security groups."
  default     = "1.2.3.4/32"
}

