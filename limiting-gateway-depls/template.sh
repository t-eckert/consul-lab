#!/bin/bash

CONSUL_K8S=~/repos/consul-k8s
HELM_CHART=~/repos/consul-k8s/charts/consul

helm template consul $HELM_CHART -f ./consul-values.yaml 


