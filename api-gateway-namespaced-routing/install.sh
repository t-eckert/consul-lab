#!/bin/bash
# Constants
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
HELM_CHART=~/Repos/consul-k8s/charts/consul
CLUSTER_NAME=test-audit


echo "Creating Consul namespace..."
kubectl create namespace consul

echo "Loading Consul Enterprise license into Kind cluster..."
kubectl create secret generic consul-enterprise-license --from-literal="license=$CONSUL_ENT_LICENSE" -n consul

echo "Installing Consul Helm chart..."
helm install consul $HELM_CHART -n consul \
	--set global.image=hashicorp/consul-enterprise:local \
	--set global.imageK8S=hashicorppreview/consul-k8s-control-plane:1.4.0-dev \
	--set global.enableConsulNamespaces=true \
	--set global.logLevel=trace \
	--set global.enterpriseLicense.secretName=consul-enterprise-license \
	--set global.enterpriseLicense.secretKey=license

