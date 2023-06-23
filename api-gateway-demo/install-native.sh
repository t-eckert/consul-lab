#!/bin/bash

# Install of Consul on Kubernetes 1.2
HELM_CHART=$GOPATH/src/github.com/hashicorp/consul-k8s/charts/consul


helm install consul $HELM_CHART -f ./consul-1.16-managed.yaml --namespace consul --create-namespace --wait
