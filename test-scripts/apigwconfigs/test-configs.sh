#!/bin/bash

PATH_TO_CONSUL=$GOPATH/src/github.com/hashicorp/consul
CONSUL_BRANCH="stub-apigw-config-entries"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Compile Consul branch
cd $PATH_TO_CONSUL
git checkout $CONSUL_BRANCH
git pull
make dev # This will compile Consul into ./bin

# Run Consul Agent
$(./bin/consul agent -dev -node machine > /dev/null) &
echo "Waiting for Consul agent to start"
sleep 5 # Give it time to start up

# Test that we can hit the agent
./bin/consul members

# Write and read a config we know should work
./bin/consul config write $SCRIPT_DIR/servicedefaults.json
./bin/consul config read -kind service-defaults -name web

# Attempt to write then read one of each configurations
./bin/consul config write $SCRIPT_DIR/apigatewayconfig.json
./bin/consul config read -kind api-gateway -name apigateway

./bin/consul config write $SCRIPT_DIR/inlinecertificate.json
./bin/consul config read -kind inline-certificate -name inlinecertificate

./bin/consul config write $SCRIPT_DIR/httproute.json
./bin/consul config read -kind http-route -name httproute

# BoundAPIGateway is only implemented in the Agent and must be PUT to the REST interface
echo "Bound API Gateway should return 'only writeable by controller'"
curl -X PUT http://localhost:8500/v1/config \
	-H "Content-Type: application/json" \
	-d @$SCRIPT_DIR/boundapigateway.json

# Stop the Agent process
echo "Stopping Consul Agent"
lsof -t -i tcp:8300 | xargs kill

