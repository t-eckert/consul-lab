name          = "Gossip Autogen"
description   = "Deploys Consul with an automatically generated gossip encryption key."
consul-values = "consul-values.yaml"
environment   = "kubernetes"

kubernetes {
  resources = [
    "client",
    "server",
  ]
}
