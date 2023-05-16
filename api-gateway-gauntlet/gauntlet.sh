#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Constants
PATH_TO_CONSUL_K8S=$GOPATH/src/github.com/hashicorp/consul-k8s
CLUSTER_NAME=gateway-gauntlet

echo -e ">>> Running preflight checklist..."

echo -n "Checking if you have a Kind cluster available for this test... "
target=$(kind get clusters | grep $CLUSTER_NAME)
if [ "$target" = "" ] 
then
	echo "Nope, creating a Kind cluster for this test..."
	kind create cluster -n $CLUSTER_NAME
else
	echo "You have a cluster called $CLUSTER_NAME."
fi

echo "Compiling Consul on Kubernetes..."
cd $PATH_TO_CONSUL_K8S
make control-plane-dev-docker
cd -

echo "Uploading the image to Kind..."
docker tag consul-k8s-control-plane-dev:latest consul-k8s-control-plane-dev:gauntlet
kind load docker-image consul-k8s-control-plane-dev:gauntlet -n $CLUSTER_NAME

echo "Installing Consul on Kubernetes..."
cd $PATH_TO_CONSUL_K8S
helm install consul ./charts/consul -n consul --create-namespace -f $SCRIPT_DIR/consul-values.yaml
cd -

echo -e "\n\n\n>>> Running the gauntlet..."

echo "Creating a GatewayClassConfig..."
kubectl apply -f $SCRIPT_DIR/gatewayclassconfig.yaml
if [ "$(kubectl get gatewayclassconfigs gateway-class-config -o json | jq '.metadata.finalizers[0]')" = "gateway-class-exists-finalizer.consul.hashicorp.com" ]
then
	echo "GatewayClassConfig has the correct finalizer!"
else
	echo "GatewayClassConfig missing finalizer gateway-class-exists-finalizer.consul.hashicorp.com"
fi


echo -e "\n\n\n>>> Gauntlet complete"
echo "Run cleanup.sh to clean up resources."

