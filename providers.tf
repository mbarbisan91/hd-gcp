terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }

    google = {
      source  = "hashicorp/google"
      version = "6.21.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.1"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

provider "kubernetes" {
  alias                  = "cluster"
  host                   = google_container_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

#provider "kubernetes" {
#  alias                  = "cluster_europe"
#  host                   = google_container_cluster.cluster_europe.endpoint
#  cluster_ca_certificate = base64decode(google_container_cluster.cluster_europe.master_auth[0].cluster_ca_certificate)
#  token                  = data.google_client_config.default.access_token
#}

provider "kubectl" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    host                   = google_container_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
}

data "google_client_config" "default" {}