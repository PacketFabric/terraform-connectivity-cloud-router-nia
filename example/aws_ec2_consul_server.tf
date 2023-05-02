resource "aws_security_group" "ingress_all_2" {
  provider = aws
  name     = "${random_pet.name.id}-sg2"
  vpc_id   = aws_vpc.vpc_1.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}"]
  }
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.my_ip}"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.aws_vpc_cidr1}"]
  }
  // Terraform removes the default rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${random_pet.name.id}"
  }
}

# Create NIC for the EC2 instances
resource "aws_network_interface" "nic2" {
  provider        = aws
  subnet_id       = aws_subnet.subnet_1.id
  security_groups = ["${aws_security_group.ingress_all_2.id}"]
  tags = {
    Name = "${random_pet.name.id}"
  }
}

# Get the environement variables
data "external" "env" {
  program = ["./env.sh"]
}

# Create the Key Pair
resource "aws_key_pair" "ssh_key_1" {
  provider   = aws
  key_name   = "ssh_key-${random_pet.name.id}"
  public_key = var.public_key
  tags = {
    Name = "${random_pet.name.id}"
  }
}

# Create the Ubuntu EC2 instances
resource "aws_instance" "ec2_instance_consul_server" {
  provider      = aws
  ami           = var.ec2_ami1
  instance_type = var.ec2_instance_type
  network_interface {
    network_interface_id = aws_network_interface.nic2.id
    device_index         = 0
  }
  key_name = aws_key_pair.ssh_key_1.id
  user_data = templatefile("user-data-ubuntu-consul-server.tpl", {
    aws_region            = var.aws_region1,
    aws_vpc_id            = aws_vpc.vpc_1.id,
    aws_pop               = var.aws_pop,
    google_project        = var.gcp_project_id,
    google_region         = var.gcp_region1,
    google_network        = google_compute_network.vpc_1.name,
    google_pop            = var.google_pop,
    PF_TOKEN              = data.external.env.result["PF_TOKEN"],
    PF_ACCOUNT_ID         = data.external.env.result["PF_ACCOUNT_ID"],
    PF_AWS_ACCOUNT_ID     = data.external.env.result["PF_AWS_ACCOUNT_ID"],
    AWS_ACCESS_KEY_ID     = data.external.env.result["AWS_ACCESS_KEY_ID"],
    AWS_SECRET_ACCESS_KEY = data.external.env.result["AWS_SECRET_ACCESS_KEY"],
    GOOGLE_CREDENTIALS    = base64encode(data.external.env.result["GOOGLE_CREDENTIALS"])
  })
  tags = {
    Name = "consul-server-${random_pet.name.id}"
  }
}

# Assign a public IP to both EC2 instances
resource "aws_eip" "public_ip_2" {
  provider = aws
  instance = aws_instance.ec2_instance_consul_server.id
  vpc      = true
  tags = {
    Name = "${random_pet.name.id}"
  }
}

# Private IPs of the demo Ubuntu instances
output "aws_ec2_private_ip_server" {
  description = "Private ip address for EC2 instance consul server"
  value       = aws_instance.ec2_instance_consul_server.private_ip
}

# Public IPs of the demo Ubuntu instances
output "aws_ec2_public_ip_server" {
  description = "Elastic ip address for EC2 instance consul server (ssh user: ubuntu)"
  value       = aws_eip.public_ip_2.public_ip
}