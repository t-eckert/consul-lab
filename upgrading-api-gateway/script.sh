#!/bin/bash

cat << EOM 
DEMO: Upgrading from Legacy to Native API Gateways

This script demos the workflow of a user upgrading from the existing Legacy API Gateway
to the new Native API Gateway.

It begins by installing Consul on Kubernetes 1.1 with Consul 1.15.
It creates several resources to demonstrate the upgrade process.
It then upgrades to Consul on Kubernetes 1.2 with Consul 1.16.
It switches the existing gateways to use the new Native API Gateway.

EOM

# Constants
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PATH_TO_CONSUL_K8S=$GOPATH/src/github.com/hashicorp/consul-k8s
CLUSTER_NAME=gateway-upgrade

echo "Creating a new kind cluster named $CLUSTER_NAME"
kind create cluster --name $CLUSTER_NAME

echo "Installing Gateway CRDs (No-longer required with Native implementation)"
kubectl apply --kustomize="github.com/hashicorp/consul-api-gateway/config/crd?ref=v0.5.4"

echo "Installing Consul on Kubernetes 1.1 with Consul 1.15"
helm install consul hashicorp/consul --version 1.1.1 --namespace consul --create-namespace -f $SCRIPT_DIR/config-0.yaml --wait

echo "Installing resources"
kubectl apply -f $SCRIPT_DIR/resources.yaml

cat << EOM 
There is now an installation of the Legacy API Gateway running locally on Kind.
To test it out, try running the following command in a separate window:

curl 

You should see the following output:

"Hello Consulate!"

When you are ready to continue and run the upgrade, press ENTER.

EOM

read

echo "Upgrading to Consul on Kubernetes 1.2 with Consul 1.16"
helm upgrade consul $PATH_TO_CONSUL_K8S/charts/consul --namespace consul --set connectInject.apiGateway.manageExternalCRDs=false -f $SCRIPT_DIR/config-1.yaml --wait

cat << EOM
A new version of Consul is now running on the cluster.
The controllers that manage the Native API Gateway are now running, but they won't pick up on the Gateway
because it still points to the Legacy API Gateway GatewayClass.

The script will now edit the Gateway to point to the Native GatewayClass.

EOM


cat << EOM
The demo is finished running.

To clean up resources created by the script, press ENTER.

EOM

read

kind delete cluster --name $CLUSTER_NAME
