#!/bin/bash

CONSUL_K8S=~/Repos/consul-k8s
HELM_CHART=~/Repos/consul-k8s/charts/consul

cd $CONSUL_K8S
make control-plane-dev-docker
docker tag consul-k8s-control-plane-dev consul-k8s-control-plane-dev:local
kind load docker-image consul-k8s-control-plane-dev:local -n one
cd -

# Load enterprise secret
kubectl create namespace consul
kubectl create secret generic consul-enterprise-license --from-literal="license=$CONSUL_ENT_LICENSE" -n consul

helm install consul $HELM_CHART -f consul-values.yaml --namespace consul --create-namespace --wait
