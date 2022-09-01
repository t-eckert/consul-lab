name          = "Connection"
description   = "Deploys a client and server and connects them."
consul-values = "consul-values.yaml"
environment   = "kubernetes"

kubernetes {
  resources = [
    "client",
    "server",
  ]
}
