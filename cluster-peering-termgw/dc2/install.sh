#!/bin/bash

cd "$(dirname "$0")"

eval $(doormat aws export --account consul_apigateway_dev)

helm install consul hashicorp/consul --version 1.1.5 -f consul-values.yaml --namespace consul --create-namespace --wait

k apply -f backend.yaml -f web.yaml
