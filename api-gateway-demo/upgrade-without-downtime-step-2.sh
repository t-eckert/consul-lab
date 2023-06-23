#!/bin/bash

# Upgrade to Consul on Kubernetes 1.2 without downtime
HELM_CHART=$GOPATH/src/github.com/hashicorp/consul-k8s/charts/consul

helm upgrade consul $HELM_CHART -f ./consul-1.16-not-managed.yaml --namespace consul --create-namespace --wait
