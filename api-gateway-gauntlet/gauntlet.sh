#!/bin/bash

# Constants
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PATH_TO_CONSUL_K8S=$GOPATH/src/github.com/hashicorp/consul-k8s
CLUSTER_NAME=gateway-gauntlet

# Functions
function success {
    local message="$1"
    echo "✅ $message"
}

function failure {
    local message="$1"
    echo "❌ $message"
}

# Script
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
helm install consul ./charts/consul -n consul --create-namespace -f $SCRIPT_DIR/consul-values.yaml --wait
cd -

echo -e "\n\n>>> Running the gauntlet..."

echo "Creating Gateway resources..."
kubectl apply -f $SCRIPT_DIR/gateway-resources.yaml

echo "Waiting for the controller to write finalizers..."
for (( i=5; i>=0; i-- ))
do
	echo -n "$i "
	sleep 1
done
echo "done"

if [[ "$(kubectl get gatewayclassconfigs gateway-class-config -o json | jq '.metadata.finalizers[0]')" == "\"gateway-class-exists-finalizer.consul.hashicorp.com\"" ]]
then
	success "GatewayClassConfig has the correct finalizer!"
else
	failure "GatewayClassConfig missing finalizer gateway-class-exists-finalizer.consul.hashicorp.com"
fi

if [[ "$(kubectl get gatewayclass gatewayclass -o json | jq '.metadata.finalizers[0]')" == "\"gateway-exists-finalizer.consul.hashicorp.com\"" ]]
then
	success "GatewayClass has the correct finalizer!"
else
	failure "GatewayClass missing finalizer gateway-exists-finalizer.consul.hashicorp.com"
fi

if [[ "$(kubectl get gateway gateway -n default -o json | jq '.metadata.finalizers[0]')" == "\"gateway-finalizer.consul.hashicorp.com\"" ]]
then
	success "Gateway has the correct finalizer!"
else
	failure "Gateway missing finalizer gateway-exists-finalizer.consul.hashicorp.com"
fi

echo "Creating the server..."
kubectl apply -f $SCRIPT_DIR/server.yaml

echo -e "\n\n>>> Gauntlet complete"

current_time=$(date "+%Y.%m.%d-%H.%M.%S")

if [ ! -d "$SCRIPT_DIR/logs" ]
then
	mkdir $SCRIPT_DIR/logs
fi

echo "Writing controller logs to $SCRIPT_DIR/logs/controller-$current_time.txt"
kubectl logs -n consul -l component=connect-injector --tail -1 > $SCRIPT_DIR/logs/controller-$current_time.txt

echo "Run cleanup.sh to clean up resources."

