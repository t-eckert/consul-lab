#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo ">>> Cleaning up resources from the gauntlet..."

echo "Remove Gateway custom resources? (y/n)"
read do_
if [ "$do_consul_removal" = "y" ]
then
	echo "Removing Gateway custom resources..."
	cd $SCRIPT_DIR
	kubectl delete -f gatewayclassconfig.yaml
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

