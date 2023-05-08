resource "google_compute_firewall" "ssh-rule1" {
  provider = google
  name     = "${random_pet.name.id}-1"
  network  = google_compute_network.vpc_1.name
  allow {
    protocol = "all"
  }
  source_ranges = ["${var.aws_vpc_cidr1}", "${var.gcp_subnet_cidr1}"]
}

resource "google_compute_firewall" "ssh-rule2" {
  provider = google
  name     = "${random_pet.name.id}-2"
  network  = google_compute_network.vpc_1.name
  allow {
    protocol = "tcp"
    ports    = ["22", "8089"]
  }
  source_ranges = ["${var.my_ip}"]
}

resource "google_compute_instance" "vm_consul_client" {
  provider     = google
  name         = "${random_pet.name.id}-nginx"
  machine_type = "e2-micro"
  zone         = var.gcp_zone1
  tags         = ["${random_pet.name.id}"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet_1.name
    access_config {}
  }
  metadata_startup_script = templatefile("user-data-ubuntu-consul-client-nginx-google.tpl", {
    consul_server_private_ip = aws_instance.ec2_instance_consul_server.private_ip
  })
  metadata = {
    sshKeys = "ubuntu:${var.public_key}"
  }
  depends_on = [time_sleep.wait_consul_server_up]
}

data "google_compute_instance" "vm_consul_client_data" {
  provider = google
  name     = "${random_pet.name.id}-nginx"
  zone     = var.gcp_zone1
  depends_on = [
    google_compute_instance.vm_consul_client
  ]
}

output "google_private_ip_vm_consul_client" {
  description = "Private ip address for VM for Region 1"
  value       = data.google_compute_instance.vm_consul_client_data.network_interface.0.network_ip
}

output "google_public_ip_vm_consul_client" {
  description = "Public ip address for VM for Region 1 (ssh user: ubuntu)"
  value       = data.google_compute_instance.vm_consul_client_data.network_interface.0.access_config.0.nat_ip
}