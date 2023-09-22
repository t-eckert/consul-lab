#!/bin/bash

ROOT=~/repos/consul-lab/cluster-peering-termgw
CONSUL_DIR=~/repos/consul
DC1=eks-dc1
DC2=eks-dc2

cat README.md
read -p "Press enter to continue"

echo "DC1::Installing Consul"
kubectl config use-context $DC1
cd $ROOT/dc1/
cat consul-values.yaml
helm install consul hashicorp/consul --version 1.2.1 -f consul-values.yaml --namespace consul --create-namespace --wait

echo "DC1::Applying mesh and proxy defaults for peering"
cd $ROOT/dc1/resources/
kubectl apply -f peering.yaml

echo "DC1::Applying peering-acceptor"
cd $ROOT/dc1/resources/
kubectl apply -f peering-acceptor.yaml

echo "DC2::Installing Consul"
kubectl config use-context $DC2
cd $ROOT/dc2/
cat consul-values.yaml
helm install consul hashicorp/consul --version 1.2.1 -f consul-values.yaml --namespace consul --create-namespace --wait

echo "DC2::Applying intentions"
kubectl apply -f intentions.yaml

echo "DC2::Applying mesh and proxy defaults for peering"
cd $ROOT/dc2/resources/
kubectl apply -f peering.yaml

echo "PEERING::Copying token DC1->DC2"
cd $ROOT
kubectl --context=$DC1 --namespace consul get secret peering-token-dc2 -o yaml | kubectl --context=$DC2 --namespace consul apply -f -

echo "DC2::Applying peering-dialer"
cd $ROOT/dc2/resources/
kubectl apply -f peering-dialer.yaml

echo "PEERING::Waiting..."
sleep 30

echo "PEERING::Verifying peer"
kubectl exec --namespace=consul -it --context=$DC1 consul-consul-server-0 \
-- curl --cacert /consul/tls/ca/tls.crt --header "X-Consul-Token: $(kubectl --context=$DC1 --namespace=consul get secrets consul-consul-bootstrap-acl-token -o go-template='{{.data.token|base64decode}}')" "https://127.0.0.1:8501/v1/peering/dc2" \
 | jq '.State' 

echo "DC1::Applying frontend"
kubectl config use-context $DC1
cd $ROOT/dc1/resources/
kubectl apply -f frontend.yaml

echo "DC1::Exporting frontend service to DC2"
kubectl apply -f exported-services.yaml

echo "DC2::Applying backend"
kubectl config use-context $DC2
cd $ROOT/dc2/resources/
kubectl apply -f backend.yaml

echo "DC2::Applying external-google"
kubectl apply -f external-google.yaml



