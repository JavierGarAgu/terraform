# Create a Google Compute Network named "my-network"
resource "google_compute_network" "default" {
  name = "my-network"
}

# Create a Google Compute Subnetwork named "my-subnet" within "my-network"
resource "google_compute_subnetwork" "default" {
  name          = "my-subnet"
  ip_cidr_range = "10.0.0.0/16"
  network       = google_compute_network.default.id
}

# Create a firewall rule to allow HTTP, SSH, RDP, and ICMP traffic
resource "google_compute_firewall" "mynetwork-allow-http-ssh-rdp-icmp" {
  name    = "mynetwork-allow-http-ssh-rdp-icmp"
  network = google_compute_network.default.self_link

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "3389"]
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}

# Create a Google Compute Internal Address within "my-subnet"
resource "google_compute_address" "internal_with_subnet_and_address" {
  name         = "my-internal-address"
  subnetwork   = google_compute_subnetwork.default.id
  address_type = "INTERNAL"
  address      = "10.0.42.42"
}

# Fetch the Debian 11 image from Google Cloud
data "google_compute_image" "debian_image" {
  family  = "debian-11"
  project = "debian-cloud"
}

# Create a Google Compute Instance named "vm-instance" with an internal IP address
resource "google_compute_instance" "instance_with_ip" {
  name         = "vm-instance"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_image.self_link
    }
  }

  network_interface {
    network    = google_compute_network.default.id
    subnetwork = google_compute_subnetwork.default.id
    network_ip = google_compute_address.internal_with_subnet_and_address.id
    access_config {}
  }
}
