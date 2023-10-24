# Cluster Peering Terminating Gateway

This experiment tests a configuration where two Consul clusters in separate Kubernetes clusters are connected
using a cluster peering. One cluster has a terminating gateway and the other has a service that should be
able to reach the external service configured for the terminating gateway.

```text
__ dc1 ________________          __ dc2 ________________
|  ____________       |          |  ___________        |
|  |          |       |          |  |         |        |        ___________
|  | frontend |       |          |  | backend |        |        |         |
|  |__________|       |          |  |_________|        |        |   web   |
|        |            |          |         |           |        |_________|
|        |    ___________     ___________  |  _______________       | 
|        |    |         |     |         |  -->|             |       | 
|        ---->|  Mesh   |---->|  Mesh   |---->| Terminating |-------- 
|             | Gateway |     | Gateway |     |   Gateway   |       |
|             |_________|     |_________|     |_____________|    ____________
|                     |          |                     |         |          |
|_____________________|          |_____________________|         | external |
                                                                 |__________|
```

If you want to use this with ACLs enabled, be sure to follow [the steps in this tutorial](https://developer.hashicorp.com/consul/docs/k8s/connect/terminating-gateways#update-terminating-gateway-acl-role-if-acls-are-enabled).
Or you could go login to the Consul UI and give the Terminating Gateway Role the Global Management Policy (this is a bad
idea and should only be used for testing.) 

## Setup
Run `run-experiment.sh`

### Register Services
You will need to register the web and external service with the consul server (after port-forwarding it). Example:
```shell
# Port-forward Consul Server
kubectl config use-context dc2
kubectl port-forward pod/consul-consul-server-0 -n consul 8501
```
```shell
# NOTE this isn't secure
cd dc2/resources
export YOUR_CONSUL_TOKEN=$(kubectl get secrets -n consul consul-consul-bootstrap-acl-token -o json | jq -r '.data.token' | base64 --decode)
curl --request PUT --data @web.json https://localhost:8501/v1/catalog/register --header "X-Consul-Token: $YOUR_CONSUL_TOKEN" -k
curl --request PUT --data @external.json https://localhost:8501/v1/catalog/register --header "X-Consul-Token: $YOUR_CONSUL_TOKEN" -k
```

### Hit the TermGW services from fronted
```shell
curl http://web.virtual.dc2.consul
curl http://external.virtual.dc2.consul
```

### Deregister Services (without cleaning up everything)
To deregister these services, just edit the `deregister.json` file to include the name of the service you would like to deregister.
```shell
# NOTE this isn't secure
cd dc2/resources
export YOUR_CONSUL_TOKEN=$(kubectl get secrets -n consul consul-consul-bootstrap-acl-token -o json | jq -r '.data.token' | base64 --decode)
curl --request PUT --data @deregister.json https://localhost:8501/v1/catalog/deregister --header "X-Consul-Token: $YOUR_CONSUL_TOKEN" -k
```

## Cleanup
Run `delete.sh`

## Known issues
This will not work if the service is of type tcp. This is a bug in Consul.
