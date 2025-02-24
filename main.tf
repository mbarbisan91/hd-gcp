
resource "google_container_cluster" "cluster" {
  name                = "demo-europe"
  location            = var.zone_eu
  deletion_protection = false
  initial_node_count  = 1
  network             = google_compute_network.vpc_network.self_link
  subnetwork          = google_compute_subnetwork.subnet_ue.self_link
  
  vertical_pod_autoscaling {
    enabled = true
  }

  node_config {
    machine_type = "e2-standard-4"
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    labels = {
      env = var.project
    }
  }
}

resource "google_container_cluster" "cluster_europe" {
  name                = "demo-europe2"
  location            = var.zone
  deletion_protection = false
  initial_node_count  = 1
  network             = google_compute_network.vpc_network.self_link
  subnetwork          = google_compute_subnetwork.subnet_europe_west1.self_link

  vertical_pod_autoscaling {
    enabled = true
  }

  node_config {
    machine_type = "e2-standard-4"
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    labels = {
      env = var.project
    }
  }
}

resource "google_container_node_pool" "default_node_pool_eu" {
  name       = "${google_container_cluster.cluster.name}-node-pool"
  cluster    = google_container_cluster.cluster.name
  location   = google_container_cluster.cluster.location
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  node_config {
    machine_type = "e2-standard-4"
  }
}

resource "google_container_node_pool" "default_node_pool_europe" {
  name       = "${google_container_cluster.cluster_europe.name}-node-pool"
  cluster    = google_container_cluster.cluster_europe.name
  location   = google_container_cluster.cluster_europe.location
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  node_config {
    machine_type = "e2-standard-4"
  }
}