#!/bin/bash

# Constants
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
HELM_CHART=~/Repos/consul-k8s/charts/consul
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

