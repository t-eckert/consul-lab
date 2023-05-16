#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CLUSTER_NAME=gateway-gauntlet

echo ">>> Cleaning up resources from the gauntlet..."

echo "Remove Gateway resources? (y/n) "
read do_gateway_resources_removal
if [ "$do_gateway_resources_removal" = "y" ]
then
	echo "Removing Gateway resources..."
	cd $SCRIPT_DIR
	kubectl delete -f gateway-resources.yaml 
	cd -
fi

echo "Remove server resources? (y/n) "
read do_server_removal
if [ "$do_server_removal" = "y" ]
then
	echo "Removing server resources..."
	cd $SCRIPT_DIR
	kubectl delete -f server.yaml 
	cd -
fi

echo "Remove Consul from the cluster? (y/n) "
read do_consul_removal
if [ "$do_consul_removal" = "y" ]
then
	echo "Uninstalling Consul on Kubernetes..."
	helm uninstall consul -n consul
fi

echo "Delete the Kind cluster? (y/n) "
read do_cluster_deletion
if [ "$do_cluster_deletion" = "y" ] 
then
	echo "Deleting Kind cluster..."
	kind delete cluster -n $CLUSTER_NAME
fi

