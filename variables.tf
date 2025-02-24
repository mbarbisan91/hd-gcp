variable "project" {
  description = "El ID del proyecto de Google Cloud"
  type        = string
  default     = "my-holded-test-project"
}

variable "region" {
  description = "La región de Google Cloud West"
  type        = string
  default     = "europe-west1"
}

variable "region_eu" {
  description = "La región de Google Cloud EU west2"
  type        = string
  default     = "europe-west2"
}

variable "zone" {
  description = "La zona de Google Cloud West"
  type        = string
  default     = "europe-west1-b"
}

variable "zone_eu" {
  description = "La zona de Google Cloud west2"
  type        = string
  default     = "europe-west2-a"
}

#Artifactory for docker image
variable "repo_name" {
  description = "Nombre del Artifact Registry"
  type        = string
  default     = "my-go-app"
}

#Docker imagen name/app name
variable "image_name" {
  description = "Image Docker"
  type        = string
  default     = "my-go-app"
}

#Install apps for administration?

variable "install_vault" {
  description = "Install Istio?"
  type        = bool
  default     = false
}

variable "install_argocd" {
  description = "Install Istio?"
  type        = bool
  default     = false
}

variable "install_istio" {
  description = "Install Istio?"
  type        = bool
  default     = false
}

variable "install_kyverno" {
  description = "Install kyverno?"
  type        = bool
  default     = false
}

variable "install_kyverno_policies" {
  description = "Install kyverno policies?"
  type        = bool
  default     = false
}

#Apps for logging y monitoring

variable "install_prometheus" {
  description = "Install Prometheus?"
  type        = bool
  default     = false
}

variable "install_prometheus_adapter" {
  description = "Install Prometheus Adapter?"
  type        = bool
  default     = false
}

variable "install_grafana" {
  description = "Install Grafana?"
  type        = bool
  default     = false
}

#Artifactory for docker image
variable "app_name" {
  description = "Nombre del Artifact Registry"
  type        = string
  default     = "my-go-app"
}

variable "app_repository" {
  description = "Github app repository"
  type        = string
  default     = "https://github.com/mbarbisan91/hd-test"
}

variable "app_branch" {
  description = "Github branch"
  type        = string
  default     = "master"
}

variable "app_path" {
  description = "Github branch"
  type        = string
  default     = "k8s"
}