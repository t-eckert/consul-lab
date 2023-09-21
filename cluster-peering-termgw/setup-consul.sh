#!/bin/bash

CONSUL_DIR=~/repos/consul

cd $CONSUL_DIR
make dev-docker
docker tag consul:local teckerthashicorp/consul:dev
docker push teckerthashicorp/consul:dev
cd -
