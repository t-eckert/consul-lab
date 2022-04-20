name          = "Unsecure"
description   = "Deploys Consul without security."
consul-values = "consul-values.yaml"
environment   = "kubernetes"

kubernetes {
  resources = [
  ]
}
