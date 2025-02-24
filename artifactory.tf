resource "google_artifact_registry_repository" "docker_registry" {
  provider      = google
  project       = var.project
  location      = "europe"
  repository_id = var.repo_name
  format        = "DOCKER"

  docker_config {
    immutable_tags = false
  }
}