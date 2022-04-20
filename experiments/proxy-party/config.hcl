name          = "Proxy Party"
description   = "Deploys a bunch of resources with Consul proxies."
consul-values = "consul-values.yaml"
environment   = "kubernetes"

kubernetes {
  resources = [
    "client",
    "server",
    "ingress-gateway",
  ]
}
