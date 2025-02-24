
resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_ue" {
  name          = "my-subnet-eu-central"
  region        = var.region_eu
  network       = google_compute_network.vpc_network.self_link
  ip_cidr_range = "10.0.0.0/24"
}

resource "google_compute_subnetwork" "subnet_europe_west1" {
  name          = "my-subnet-eu-west1"
  region        = var.region
  network       = google_compute_network.vpc_network.self_link
  ip_cidr_range = "10.0.1.0/24"
}