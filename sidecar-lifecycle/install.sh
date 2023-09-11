#!/bin/bash

CONSUL_DATAPLANE=~/repos/consul-dataplane
CONSUL_K8S=~/repos/consul-k8s
HELM_CHART=~/repos/consul-k8s/charts/consul

cd $CONSUL_DATAPLANE
make docker
docker tag consul-dataplane/release-default:1.3.0-dev consul-dataplane/release-default:local
kind load docker-image consul-dataplane/release-default:local -n one
cd -

cd $CONSUL_K8S
make control-plane-dev-docker
docker tag consul-k8s-control-plane-dev consul-k8s-control-plane-dev:local
kind load docker-image consul-k8s-control-plane-dev:local -n one
cd -

helm install consul $HELM_CHART -f consul-values.yaml --namespace consul --create-namespace --wait
