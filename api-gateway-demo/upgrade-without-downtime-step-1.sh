#!/bin/bash

# Upgrade to Consul on Kubernetes 1.2 without downtime
HELM_CHART=$GOPATH/src/github.com/hashicorp/consul-k8s/charts/consul

kubectl apply -k "github.com/kubernetes-sigs/gateway-api/config/crd/experimental?ref=v0.6.2"

helm upgrade consul $HELM_CHART -f ./consul-1.16-parallel.yaml --namespace consul --create-namespace --wait
