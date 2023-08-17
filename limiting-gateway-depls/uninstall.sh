#!/bin/bash


consul-k8s uninstall -wipe-data -auto-approve

kubectl delete -f ./resources.yaml -f ./gateway.yaml -f ./httproute.yaml


