# resource "aws_security_group" "ingress_all_1" {
#   provider = aws
#   name     = "${random_pet.name.id}-sg1"
#   vpc_id   = aws_vpc.vpc_1.id
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["${var.my_ip}"]
#   }
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["${var.my_ip}"]
#   }
#   ingress {
#     from_port   = 8089
#     to_port     = 8089
#     protocol    = "tcp"
#     cidr_blocks = ["${var.my_ip}"]
#   }
#   ingress {
#     from_port   = 5001
#     to_port     = 5001
#     protocol    = "tcp"
#     cidr_blocks = ["${var.my_ip}"]
#   }
#   ingress {
#     from_port   = -1
#     to_port     = -1
#     protocol    = "icmp"
#     cidr_blocks = ["${var.my_ip}"]
#   }
#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["${var.aws_vpc_cidr1}"]
#   }
#   // Terraform removes the default rule
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "${random_pet.name.id}"
#   }
# }

# # Create NIC for the EC2 instances
# resource "aws_network_interface" "nic1" {
#   provider        = aws
#   subnet_id       = aws_subnet.subnet_1.id
#   security_groups = ["${aws_security_group.ingress_all_1.id}"]
#   tags = {
#     Name = "${random_pet.name.id}"
#   }
# }

# resource "time_sleep" "wait_consul_server_up" {
#   create_duration = "2m"
#   depends_on = [
#     aws_instance.ec2_instance_consul_server
#   ]
# }

# # Create the Ubuntu EC2 instances
# resource "aws_instance" "ec2_instance_consul_client" {
#   provider      = aws
#   ami           = var.ec2_ami1
#   instance_type = var.ec2_instance_type
#   network_interface {
#     network_interface_id = aws_network_interface.nic1.id
#     device_index         = 0
#   }
#   key_name = aws_key_pair.ssh_key_1.id
#   user_data = templatefile("user-data-ubuntu-consul-client-nginx-aws.tpl", {
#     consul_server_private_ip = aws_instance.ec2_instance_consul_server.private_ip
#   })
#   tags = {
#     Name = "nginx-${random_pet.name.id}"
#   }
#   depends_on = [time_sleep.wait_consul_server_up]
# }

# # Assign a public IP to both EC2 instances
# resource "aws_eip" "public_ip_1" {
#   provider = aws
#   instance = aws_instance.ec2_instance_consul_client.id
#   vpc      = true
#   tags = {
#     Name = "${random_pet.name.id}"
#   }
# }

# # Private IPs of the demo Ubuntu instances
# output "aws_ec2_private_ip_client" {
#   description = "Private ip address for EC2 instance for Demo nginx/consul client"
#   value       = aws_instance.ec2_instance_consul_client.private_ip
# }

# # Public IPs of the demo Ubuntu instances
# output "aws_ec2_public_ip_client" {
#   description = "Elastic ip address for EC2 instance for Demo nginx/consul client (ssh user: ubuntu)"
#   value       = aws_eip.public_ip_1.public_ip
# }