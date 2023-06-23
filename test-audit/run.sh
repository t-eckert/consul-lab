#!/bin/bash

# Constants
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
HELM_CHART=$GOPATH/src/github.com/hashicorp/consul-k8s/charts/consul
CLUSTER_NAME=test-audit

echo -n "Checking if you have CONSUL_ENT_LICENSE set..."
if [ -z "$CONSUL_ENT_LICENSE" ]
then
	echo "Nope, please set CONSUL_ENT_LICENSE to your Consul Enterprise license."
	exit 1
else
	echo "Yes, you have a Consul Enterprise license."
fi

echo -n "Checking if you have a Kind cluster available for this test... "
target=$(kind get clusters | grep $CLUSTER_NAME)
if [ "$target" = "" ] 
then
	echo "Nope, creating a Kind cluster for this test..."
	kind create cluster -n $CLUSTER_NAME
else
	echo "You have a cluster called $CLUSTER_NAME."
fi

echo "Creating Consul namespace..."
kubectl create namespace consul

echo "Loading Consul Enterprise license into Kind cluster..."
kubectl create secret generic consul-enterprise-license --from-literal="license=$CONSUL_ENT_LICENSE" -n consul

echo "Installing Consul Helm chart..."
helm install consul $HELM_CHART -n consul \
	--set global.image=teckerthashicorp/consul-enterprise:2023-06-22 \
	--set global.imageK8S=hashicorppreview/consul-k8s-control-plane:1.2.0-dev \
	--set global.logLevel=trace \
	--set global.acls.manageSystemACLs=true \
	--set global.enterpriseLicense.secretName=consul-enterprise-license \
	--set global.enterpriseLicense.secretKey=license \
	--set server.auditLogs.enabled=true

