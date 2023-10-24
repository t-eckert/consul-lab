#!/bin/bash

ROOT=~/Projects/consul-lab/cluster-peering-termgw
CONSUL_DIR=~/repos/consul
DC1=dc1
DC2=dc2

read -p "Press enter to continue DELETING"

echo "DC2::Deleting resources"
kubectl config use-context $DC2
cd $ROOT/dc2/resources/
kubectl delete -f .

echo "DC2::Uninstall Consul"
kubectl config use-context $DC2
cd $ROOT/dc2/
helm uninstall consul -n consul

echo "DC2::Deleting peering secret"
kubectl config use-context $DC2
cd $ROOT/dc2/resources/
kubectl delete secret -n consul peering-token-dc2

echo "DC1::Deleting resources"
kubectl config use-context $DC1
cd $ROOT/dc1/resources/
kubectl delete -f .

echo "DC1::Uninstall Consul"
kubectl config use-context $DC1
cd $ROOT/dc1/
helm uninstall consul -n consul


