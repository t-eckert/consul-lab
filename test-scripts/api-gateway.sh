#!/bin/bash

PATH_TO_CONSUL_K8S=$GOPATH/src/github.com/hashicorp/consul-k8s

# Compile image
cd $PATH_TO_CONSUL_K8S
make control-plane-dev-docker

# Upload to Kind
docker tag consul-k8s-control-plane-dev:latest consul-k8s-control-plane-dev:blueberry
kind load docker-image consul-k8s-control-plane-dev:blueberry -n consul-lab

# Install Consul
helm install consul ./charts/consul -n consul --create-namespace --set global.imageK8S=consul-k8s-control-plane-dev:blueberry

