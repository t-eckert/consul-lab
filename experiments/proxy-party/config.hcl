name          = "Proxy Party"
description   = "Deploys a client and server with Consul CRDs."
consul-values = "consul-values.yaml"
environment   = "kubernetes"

kubernetes {
  resources = [
    "client",
    "server",
  ]
}