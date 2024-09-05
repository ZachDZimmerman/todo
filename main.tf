provider "google" {
  project = "3tierwebappmongo"
  region  = "us-west1"
}

resource "google_compute_instance" "mongodb_vm" {
  name     = "mongodb_vm"
  machine_type = "e2-medium"
  location = "us-west1-b"
  tags = ["mongodb"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  resource "google_compute_address" "mongodb_vm_external_ip" {
    name = "mongodb-vm-external-ip"
    region = "us-west1"
  }
  metadata_startup_script = "apt-get update && apt-get install -y mongodb && systemctl start mongod && systemctl enable mongod"
}

resource "google_compute_firewall" "mongodb_firewall" {
  name = "mongodb-firewall"
  network = "default"
  
  allow {
    protocol = "tcp"
    ports = ["27017"]
  }
  target_tags = ["mongodb"]
  source_ranges = ["0.0.0.0/0"]
}

#Output the external IP address of the MongoDB VM
output "mongodb_vm_external_ip" {
  value = google_compute_address.mongodb_vm_external_ip.address
}

network_interface {
    network = "default"
    access_config {
        nat_ip = google_compute_address.mongodb_vm_external_ip.address
    }
}
