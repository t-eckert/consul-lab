name          = "Secure"
description   = "Deploys Consul with Gossip Encryption, TLS, and ACLs."
consul-values = "consul-values.yaml"
environment   = "kubernetes"

kubernetes {
  resources = [
  ]
}
