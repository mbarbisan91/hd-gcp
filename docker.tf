resource "null_resource" "docker_build_push" {
  depends_on = [google_artifact_registry_repository.docker_registry]

  provisioner "local-exec" {
    command = <<EOT
      git clone https://github.com/holdedhub/devops-challenge.git
      cd devops-challenge/app
      cp ../../Dockerfile .
      docker build -t europe-docker.pkg.dev/${var.project}/${var.repo_name}/${var.image_name}:latest .
      gcloud auth configure-docker europe-docker.pkg.dev
      docker push europe-docker.pkg.dev/${var.project}/${var.repo_name}/${var.image_name}:latest
      cd ../../ && rm -rf devops-challenge/
    EOT
  }
}