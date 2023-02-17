#!/bin/bash

cleanup() {
  echo "shutting down upstreams"
}

trap 'trap " " SIGTERM; kill 0; wait; cleanup' SIGINT SIGTERM

echo "Writing gateway config entry"
cat << EOF | consul config write -
kind = "api-gateway"
name = "api-gateway"
listeners = [
  {
    port     = 9999
    protocol = "tcp"
  }
]
EOF

echo "Writing tcp route config entry"
cat << EOF | consul config write -
kind = "tcp-route"
name = "api-gateway-route"
services = [
  {
    name = "service"
  }
]
parents = [
  {
    kind = "api-gateway"
    name = "api-gateway"
  }
]
EOF

echo "Registering tcp service"
cat << EOF > /tmp/service.hcl
service {
  name = "service"
  id   = "service"
  port = 9002
}
EOF
consul services register /tmp/service.hcl

echo "Registering tcp service proxy"
cat << EOF > /tmp/proxy.hcl
service {
  kind = "connect-proxy"
  name = "service"
  id   = "service"
  port = 9001

  proxy = {
    destination_service_name  = "service"
    destination_service_id    = "service"
    local_service_address     = "127.0.0.1"
    local_service_port        = 9002
  }
}
EOF
consul services register /tmp/proxy.hcl

echo "Running tcp service"
ncat -e "/bin/echo service" -k -l 9002 &
echo "Running tcp service sidecar proxy"
consul connect envoy -sidecar-for service -admin-bind 127.0.0.1:9092 &
echo "Running api gateway"
consul connect envoy -gateway api -register -service api-gateway -proxy-id api-gateway &

wait
