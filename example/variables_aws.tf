## AWS VARs
variable "aws_region1" {
  type        = string
  description = "AWS region 1"
  default     = "us-east-1"
}
variable "aws_vpc_cidr1" { # used in PF BGP prefix
  type        = string
  description = "CIDR for the VPC in AWS Region 1"
  default     = "10.2.0.0/16"
}
# Subnet Variables
variable "aws_subnet_cidr1" {
  type        = string
  description = "CIDR for the subnet in AWS Region 1"
  default     = "10.2.1.0/24"
}
# Make sure you setup the correct AMI if you chance default AWS region1
variable "ec2_ami1" {
  description = "Ubuntu 22.04 in aws_region1 (e.g. us-east-1)"
  default     = "ami-052efd3df9dad4825"
}
variable "ec2_instance_type" {
  description = "Instance Type/Size"
  default     = "t2.micro" # Free tier
}

# PacketFabric Cloud Router Connection - AWS
variable "aws_pop" {
  type        = string
  description = "The POP in which you want to provision the connection"
  default     = "NYC1"
}