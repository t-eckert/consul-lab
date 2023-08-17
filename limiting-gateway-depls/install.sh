#!/bin/bash

CONSUL_K8S=~/repos/consul-k8s
HELM_CHART=~/repos/consul-k8s/charts/consul

cd $CONSUL_K8S
make control-plane-dev-docker
docker tag consul-k8s-control-plane-dev consul-k8s-control-plane-dev:local
kind load docker-image consul-k8s-control-plane-dev:local -n one
cd -

helm install consul $HELM_CHART -f ./consul-values.yaml --namespace consul --create-namespace --wait

kubectl apply -f ./resources.yaml -f ./gateway.yaml -f ./httproute.yaml


