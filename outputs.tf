#Registry url
output "registry_url" {
  value = "europe-docker.pkg.dev/${var.project}/${var.repo_name}"
}

#First cluster
output "kube_cluster_name" {
  value = google_container_cluster.cluster.name
}

output "kube_cluster_endpoint" {
  value = google_container_cluster.cluster.endpoint
}

output "kube_cluster_ca_certificate" {
  value = google_container_cluster.cluster.master_auth.0.cluster_ca_certificate
}

#Second cluster
output "kube_cluster_name_europe" {
  value = google_container_cluster.cluster_europe.name
}

output "kube_cluster_endpoint_europe" {
  value = google_container_cluster.cluster_europe.endpoint
}

output "kube_cluster_ca_certificate_europe" {
  value = google_container_cluster.cluster_europe.master_auth.0.cluster_ca_certificate
}