#!/bin/bash

# Install of Consul on Kubernetes 1.1 with API Gateway Legacy

kubectl apply --kustomize="github.com/hashicorp/consul-api-gateway/config/crd?ref=v0.5.4"

helm install consul hashicorp/consul -f ./consul-1.15-legacy.yaml --namespace consul --create-namespace --wait
