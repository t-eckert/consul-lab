#!/bin/bash

PATH_TO_CONSUL=$GOPATH/src/github.com/hashicorp/consul
CONSUL_BRANCH="stub-apigw-config-entries"

# Compile Consul branch
cd $PATH_TO_CONSUL
git checkout $CONSUL_BRANCH
git pull
make dev # This will compile Consul into ./bin

# Run Consul Agent
./bin/consul agent -dev -node machine &

# Test that we can hit the agent

