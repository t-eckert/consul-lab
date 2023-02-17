provider "google" {
  zone = var.dc2_zone
  project = var.project
}

resource "random_string" "suffix" {
  length = 8
  special = false
  upper = false
}

locals {
  cluster_name = "consul-peering-gke-${random_string.suffix.result}"
}

resource "google_project_service" "svc" {
  service = "${each.value}.googleapis.com"

  disable_dependent_services = true

  for_each = toset([
    "container",
  ])
}


resource "google_container_cluster" "dc1" {
  name = local.cluster_name
  location = var.dc2_zone
  initial_node_count = 3

  depends_on = [
    google_project_service.svc["container"]
  ]
}
