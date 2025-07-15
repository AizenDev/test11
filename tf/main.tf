terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  credentials = file(var.credentials_file)
  zone        = var.zone
}

resource "google_compute_disk" "my_disk_1" {
  name = "my-disk-1"
  image = var.image
  size = var.disk_size_gb
  type = var.disk_type
  zone = var.zone
}

resource "google_compute_disk" "my_disk_2" {
  name = "my-disk-2"
  image = var.image
  size = var.disk_size_gb
  type = var.disk_type
  zone = var.zone
}

resource "google_compute_instance" "vm_instance_1" {
  name         = var.vm_name_1
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    source = google_compute_disk.my_disk_1.name
  }

  network_interface {
    network = "default"
    access_config {}
  }

  tags = var.vm_tags

  metadata = {
    ssh-keys = var.ssh_public_key
  }

  service_account {
    email  = var.service_account_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

}


resource "google_compute_instance" "vm_instance_2" {
  name         = var.vm_name_2
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    source = google_compute_disk.my_disk_2.name
  }

  network_interface {
    network = "default"
    access_config {}
  }

  tags = var.vm_tags

  metadata = {
    ssh-keys = var.ssh_public_key
  }

  service_account {
    email  = var.service_account_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_compute_firewall" "allow_http" {
   name        = "allow-http"
   network     = "default"
   description = "Allow HTTP from anywhere"
   allow {
     protocol = "tcp"
     ports    = ["80"]
   }

   source_ranges = ["0.0.0.0/0"]
   target_tags = ["http"]
 }

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

output "instance_name" {
  value = google_compute_instance.vm_instance_1.name
}

output "instance_ip_1" {
  description = "External IP address of the instance"
  value       = google_compute_instance.vm_instance_1.network_interface[0].access_config[0].nat_ip
}

output "instance_ip_2" {
  description = "External IP address of the instance"
  value       = google_compute_instance.vm_instance_2.network_interface[0].access_config[0].nat_ip
}
