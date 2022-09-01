name          = "Demo"
description   = "Demo of CLI Envoy Debugging"
consul-values = "consul-values.yaml"
environment   = "kubernetes"

kubernetes {
  resources = [
    "client",
    "server",
  ]
}
