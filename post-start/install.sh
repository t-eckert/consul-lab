#!/bin/bash

CONSUL_K8S=~/repos/consul-k8s
HELM_CHART=~/repos/consul-k8s/charts/consul
CONSUL_DATAPLANE=~/repos/consul-dataplane

cd $CONSUL_DATAPLANE
make dev-docker
kind load docker-image consul-dataplane:local 
cd -

# cd $CONSUL_K8S
# make dev-docker
# kind load docker-image consul-k8s-control-plane:local
# cd -

helm install consul $HELM_CHART -f ./consul-values.yaml --namespace consul --create-namespace --wait

kubectl apply -f ../resources/server.yaml



